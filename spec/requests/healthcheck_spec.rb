require "rails_helper"

RSpec.describe "Health check", type: :request do
  it "responds successfully" do
    get "/health"
    expect(response).to have_http_status(:ok)
  end

  it "checks PostgreSQL health" do
    get "/health/postgresql"
    expect(response).to have_http_status(:ok)
  end

  it "checks Zendesk health" do
    get "/health/zendesk"
    expect(response).to have_http_status(:ok)
  end

  it "checks Notify integration health" do
    allow(Notifications::Client).to receive(:new).and_return(
      double(:client, send_email: true),
    )
    get "/health/notify"
    expect(response).to have_http_status(:ok)
  end
end
