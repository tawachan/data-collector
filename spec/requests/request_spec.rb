# frozen_string_literal: true

require 'rails_helper'

include RoutingTestHelper
include Committee::Rails::Test::Methods

RSpec.describe 'すべてのエンドポイントを確認', type: :request do
  IGNORE_PATHS = %w[apidoc sidekiq].freeze

  before do
    # seed等を実行して前提データを作る
  end

  routes(namespace: 'api', ignore_paths: IGNORE_PATHS).each do |route|
    it "#{route.name}(#{route.url})" do
      get route.url
      assert_request_schema_confirm
      assert_response_schema_confirm
      expect(response.status).to eq 200
    end
  end
end
