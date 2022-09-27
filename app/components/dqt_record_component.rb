class DqtRecordComponent < ViewComponent::Base
  def initialize(dqt_record:)
    super
    @dqt_record = dqt_record
  end

  def full_name
    @dqt_record.fetch("name", nil)
  end

  def date_of_birth
    @dqt_record.fetch("dob", nil)&.to_date&.to_fs(:long_ordinal_uk)
  end

  def nino
    @dqt_record.fetch("ni_number", nil) ? "Given" : "Not Given"
  end

  def trn
    @dqt_record["trn"]
  end

  def rows
    [name_row, date_of_birth_row, nino_row, trn_row]
  end

  def name_row
    { key: { text: "Official name" }, value: { text: full_name } }
  end

  def date_of_birth_row
    { key: { text: "Date of birth" }, value: { text: date_of_birth } }
  end

  def nino_row
    { key: { text: "National insurance number" }, value: { text: nino } }
  end

  def trn_row
    { key: { text: "TRN" }, value: { text: trn } }
  end
end
