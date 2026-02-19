require "test_helper"

class Api::V1::OnboardingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = companies(:one)
    Company.where.not(id: @company.id).destroy_all
    @company.create_onboarding_progress!(status: :in_progress) unless @company.onboarding_progress
  end

  test "should get status" do
    get api_v1_status_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_includes json.keys, "current_step"
    assert_includes json.keys, "overall_status"
    assert_includes json.keys, "steps"
    assert_includes json.keys, "sync_progress"
  end

  test "status should return current step information" do
    step = onboarding_steps(:one)
    @company.onboarding_progress.update!(current_step: step)

    get api_v1_status_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal step.id, json["current_step"]["id"]
    assert_equal step.name, json["current_step"]["name"]
    assert_equal step.slug, json["current_step"]["slug"]
  end

  test "status should return overall_status" do
    get api_v1_status_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_includes ["not_started", "in_progress", "completed"], json["overall_status"]
  end

  test "status should return steps array" do
    get api_v1_status_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_instance_of Array, json["steps"]
  end

  test "status should return sync_progress hash" do
    get api_v1_status_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_instance_of Hash, json["sync_progress"]
  end

  test "should update step successfully" do
    step = onboarding_steps(:one)
    step.update!(slug: "welcome")
    @company.onboarding_progress.update!(current_step: step)

    patch api_v1_url(slug: "welcome"), params: { step_params: {} }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "Step updated successfully", json["message"]
    assert_includes json.keys, "current_step"
    assert_includes json.keys, "overall_status"
  end

  test "should return error when step is locked" do
    step = onboarding_steps(:one)
    step.update!(required_sync_type: "products")
    @company.onboarding_progress.update!(current_step: step)

    patch api_v1_url(slug: step.slug), params: { step_params: {} }
    assert_response :locked

    json = JSON.parse(response.body)
    assert_includes json.keys, "error"
    assert_includes json["error"], "locked"
  end

  test "should get sync progress" do
    get api_v1_sync_progress_url
    assert_response :success

    json = JSON.parse(response.body)
    assert_instance_of Hash, json
    assert_includes json.keys, "products"
    assert_includes json.keys, "warehouses"
    assert_includes json.keys, "vendors"
    assert_includes json.keys, "sales_history"
  end

  test "sync progress should include sync_percent for each type" do
    get api_v1_sync_progress_url
    assert_response :success

    json = JSON.parse(response.body)
    json.each do |sync_type, data|
      assert_instance_of Hash, data
      assert_includes data.keys, "sync_percent"
    end
  end

  test "update_step with lead_time should update company setting" do
    step = onboarding_steps(:one)
    @company.onboarding_progress.update!(current_step: step)
    @company.create_company_setting! unless @company.company_setting

    patch api_v1_url(slug: "lead_time"),
          params: { step_params: { default_lead_time: 30 } }

    assert_response :success
    assert_equal 30, @company.company_setting.reload.default_lead_time
  end

  test "update_step with missing required param should return error" do
    step = onboarding_steps(:one)
    @company.onboarding_progress.update!(current_step: step)

    patch api_v1_url(slug: "lead_time"),
          params: { step_params: {} }

    assert_response :locked
    json = JSON.parse(response.body)
    assert_includes json["error"], "required"
  end

  test "update_step should allow skipping skippable steps" do
    step = onboarding_steps(:one)
    step.update!(skippable: true)
    @company.onboarding_progress.update!(current_step: step)

    patch api_v1_url(slug: "po_upload"),
          params: { step_params: { skip_step: true } }

    assert_response :success
    assert @company.onboarding_progress.reload.skipped_step?("po_upload")
  end

  test "update_step should not allow skipping non-skippable steps" do
    step = onboarding_steps(:five)
    step.update!(skippable: false)
    @company.onboarding_progress.update!(current_step: step)

    patch api_v1_url(slug: "po_upload"),
          params: { step_params: { skip_step: true } }

    assert_response :locked
    json = JSON.parse(response.body)
    assert_includes json["error"], "can't skip"
  end
end
