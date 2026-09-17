# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Log redaction" do
  let(:json) { StringIO.new }
  let(:colour) { StringIO.new }
  let(:lines) { json.string.lines.map { |line| JSON.parse(line) } }
  let(:logger) { SemanticLogger["LogRedactionSpec"] }
  let(:trn_request) { create(:trn_request, :has_trn, email: "teacher@example.com") }

  # The JSON appender Logit reads, and a colour one like the gem adds to the
  # Sidekiq server's stdout
  around do |example|
    appenders = [
      SemanticLogger.add_appender(io: json, formatter: :json, level: :info),
      SemanticLogger.add_appender(io: colour, formatter: :color, level: :info),
    ]
    example.run
    appenders.each { |appender| SemanticLogger.remove_appender(appender) }
  end

  def line_for(key, value)
    lines.find { |line| line.dig("payload", key) == value }
  end

  context "when a mail is delivered" do
    let(:delivery) { line_for("event_name", "deliver.action_mailer") }

    before do
      TeacherMailer.found_trn(trn_request).deliver_now
      SemanticLogger.flush
    end

    it "filters the subject and the addresses" do
      expect(delivery["payload"]).to include(
        "subject" => "[FILTERED]",
        "to" => "[FILTERED]",
        "from" => "[FILTERED]",
      )
    end

    it "keeps the message id, so a delivery can be tied to its failure" do
      expect(delivery.dig("payload", "message_id")).to include("@")
    end

    it "leaves no trace of the TRN or the address on any appender" do
      aggregate_failures do
        expect(colour.string).to include("Delivered mail")
        [json.string, colour.string].each do |output|
          expect(output).not_to include(trn_request.trn, "teacher@example.com")
        end
      end
    end
  end

  context "when jobs are enqueued" do
    before do
      TeacherMailer.found_trn(trn_request).deliver_later
      CheckZendeskTicketForTrnJob.perform_later(trn_request.id)
      SemanticLogger.flush
    end

    it "does not log a mail delivery's arguments" do
      mail_job = line_for("job_class", "ActionMailer::MailDeliveryJob")

      expect(mail_job.dig("payload", "arguments")).to eq("")
    end

    it "still logs other jobs' arguments" do
      other_job = line_for("job_class", "CheckZendeskTicketForTrnJob")

      expect(other_job.dig("payload", "arguments")).to include(trn_request.id.to_s)
    end
  end

  context "when the Sidekiq error handler logs a failed job" do
    it "filters the job's arguments" do
      csv = "Name,Email\nJohn Smith,teacher@example.com"
      job = {
        "wrapped" => "ActionMailer::MailDeliveryJob",
        "args" => [{ "arguments" => ["TrnExportMailer", "monthly_report", "deliver_now", { "args" => [csv] }] }],
      }
      logger.warn("Job raised exception", context: "Job raised exception", job:)
      SemanticLogger.flush

      aggregate_failures do
        expect(lines.last.dig("payload", "job", "args")).to eq("[FILTERED]")
        expect(json.string).not_to include("John Smith")
      end
    end
  end

  context "with an address in free text" do
    it "scrubs it and still writes valid JSON" do
      logger.info(
        "550 5.1.1 <teacher@example.com>: rejected",
        path: "/start?a=1&teacher@example.com",
        note: "first line\nteacher@example.com",
      )
      SemanticLogger.flush

      aggregate_failures do
        expect(lines.last["message"]).to eq("550 5.1.1 <[FILTERED]>: rejected")
        expect(lines.last["payload"]).to eq(
          "path" => "/start?a=1&[FILTERED]",
          "note" => "first line\n[FILTERED]",
        )
      end
    end
  end

  context "with an address in an exception" do
    def raised(exception)
      raise exception
    rescue exception.class => e
      e
    end

    let(:notify_error) do
      body = { errors: [{ error: "BadRequestError", message: "teacher@example.com is not valid" }] }
      raised(Notifications::Client::BadRequestError.new(Struct.new(:code, :body).new(400, body.to_json)))
    end

    it "scrubs the message and keeps the class and backtrace" do
      logger.error("Error delivering mail", notify_error)
      SemanticLogger.flush

      expect(lines.last["exception"]).to include(
        "name" => "Notifications::Client::BadRequestError",
        "message" => "BadRequestError: [FILTERED] is not valid",
        "stack_trace" => notify_error.backtrace,
      )
    end

    it "scrubs every cause" do
      nested =
        begin
          begin
            raise ArgumentError, "inner teacher@example.com"
          rescue ArgumentError
            raise "outer teacher@example.com"
          end
        rescue RuntimeError => e
          e
        end
      logger.error("Failed", nested)
      SemanticLogger.flush

      aggregate_failures do
        expect(lines.last.dig("exception", "cause", "message")).to eq("inner [FILTERED]")
        [json.string, colour.string].each do |output|
          expect(output).not_to include("teacher@example.com")
        end
      end
    end

    it "scrubs a cause whose class builds its own message" do
      details = { "requester" => [{ "description" => "Email teacher@example.com is invalid" }] }
      wrapped =
        begin
          begin
            raise ZendeskAPI::Error::RecordInvalid.new(nil, { status: 422, body: { "details" => details } })
          rescue ZendeskAPI::Error::RecordInvalid
            raise ZendeskService::CreateError, "Could not create Zendesk ticket"
          end
        rescue ZendeskService::CreateError => e
          e
        end
      logger.error("Error performing CreateZendeskTicketJob", wrapped)
      SemanticLogger.flush

      aggregate_failures do
        expect(lines.last.dig("exception", "cause", "name")).to eq("ZendeskAPI::Error::RecordInvalid")
        [json.string, colour.string].each do |output|
          expect(output).not_to include("teacher@example.com")
        end
      end
    end

    it "leaves the original exception alone" do
      logger.error("Error delivering mail", notify_error)
      SemanticLogger.flush

      expect(notify_error.message).to include("teacher@example.com")
    end

    # Copying a frozen exception raises a FrozenError that quotes the original,
    # which the failure path would then record
    it "scrubs a frozen exception without leaking it through the failure path" do
      logger.error("Error delivering mail", notify_error.freeze)
      SemanticLogger.flush

      aggregate_failures do
        expect(lines.last.dig("exception", "message")).to eq("BadRequestError: [FILTERED] is not valid")
        expect(json.string).not_to include("teacher@example.com")
      end
    end
  end

  context "with a key from config.filter_parameters" do
    it "filters it" do
      logger.info("signed in", support_password: "hunter2")
      SemanticLogger.flush

      expect(lines.last.dig("payload", "support_password")).to eq("[FILTERED]")
    end
  end

  context "with a key that only contains a mailer field name" do
    it "leaves it alone" do
      logger.info("uploaded", photo: "cat.jpg")
      SemanticLogger.flush

      expect(lines.last.dig("payload", "photo")).to eq("cat.jpg")
    end
  end

  # The payload: keyword is stored as passed, not copied
  it "does not change the payload the caller passed in" do
    payload = { subject: "Your TRN is 1234567" }
    logger.info(message: "sent", payload:)
    SemanticLogger.flush

    expect(payload).to eq(subject: "Your TRN is 1234567")
  end

  context "when redaction raises" do
    before do
      allow(Logstop).to receive(:scrub).and_raise(ArgumentError, "invalid byte sequence in UTF-8")
    end

    it "withholds the entry and records why, at error level" do
      logger.info("teacher@example.com", subject: "Your TRN is 1234567")
      SemanticLogger.flush

      aggregate_failures do
        expect(lines.last).to include(
          "level" => "error",
          "message" => "Log entry withheld: redaction failed",
          "exception" => include(
            "name" => "ArgumentError",
            "message" => "invalid byte sequence in UTF-8",
            "stack_trace" => be_present,
          ),
        )
        expect(lines.last).not_to have_key("payload")
        expect(json.string).not_to include("teacher@example.com", "1234567")
      end
    end
  end
end
