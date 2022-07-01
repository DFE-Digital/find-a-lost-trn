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
end
