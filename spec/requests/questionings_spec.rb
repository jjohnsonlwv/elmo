require "spec_helper"

# Using request spec b/c Authlogic won't work with controller spec
describe "questionings", type: :request do
  let(:user) { create(:user, role_name: "coordinator") }

  before do
    login(user)
  end

  describe "update" do
    context "when published" do
      let(:form) { create(:form, :published, question_types: %w(text text)) }
      let(:qing) { form.questionings.first }

      it "changing name should succeed" do
        put(questioning_path(qing, mode: "m", mission_name: get_mission.compact_name),
          "questioning" => {
            "question_attributes" => {
              "id" => qing.question_id,
              "name_en" => "Foo"
            }
          }
        )
        expect(response).to be_redirect
        expect(qing.reload.name_en).to eq("Foo")
      end

      it "changing required flag should be unauthorized" do
        put(questioning_path(qing, mode: "m", mission_name: get_mission.compact_name),
          "questioning" => {"required" => "1"})
        expect(response).to redirect_to(unauthorized_path)
      end

      it "changing hidden flag should be unauthorized" do
        put(questioning_path(qing, mode: "m", mission_name: get_mission.compact_name),
          "questioning" => {"hidden" => "1"})
        expect(response).to redirect_to(unauthorized_path)
      end

      it "changing condition should be unauthorized" do
        put(questioning_path(qing, mode: "m", mission_name: get_mission.compact_name),
          "questioning" => {
            "condition_attributes" => {
              "ref_qing_id" => form.questionings[0].id,
              "op" => "eq",
              "value" => "foo"
            }
          }
        )
        expect(response).to redirect_to(unauthorized_path)
      end
    end
  end

  describe "condition_form_data" do

    #set up form like above w/ four questionings, have the qing be the third one.
    let(:form) { create(:form, :published, question_types: %w(integer text integer text)) }
    let(:qing) { form.questionings[2] }

    context "without ref_qing_id" do
      it "returns json with ref qing id options, no operator options, and no value options" do

        puts "role: #{user.role(form.mission)}"


        get "/en/m/#{get_mission.compact_name}/questionings/condition-form", {ref_qing_id: nil, form_id: form.id, questioning_id: qing.id}
        expect(response).to have_http_status(200)

        expected_ref_qing_options = form.questionings.select{ |q| q.id < qing.id }.map{ |q| {code: q.question.code, rank: q.full_dotted_rank, id: q.id} }
        expected = {
          id: nil,
          ref_qing_id: nil,
          op: nil,
          value: nil,
          form_id: form.id,
          questioning_id: qing.id,
          refable_qing_options: expected_ref_qing_options,
          operator_options: [],
          value_options: nil
        }.to_json
        expect(response.body).to eq expected
      end
    end

    context "with ref_qing_id" do # ref_qing_id: 21. return all refqings, and operators, and options type.
      it "returns json with operator options" do
        expected_ref_qing_options = form.questionings.select{ |q| q.id < qing.id }.map{ |q| {code: q.question.code, rank: q.full_dotted_rank, id: q.id} }
        get "/en/m/#{get_mission.compact_name}/questionings/condition-form", {ref_qing_id: form.questionings[0].id , form_id: form.id, questioning_id: qing.id}
        expect(response).to have_http_status(200)

        expected = {
          id: nil,
          ref_qing_id: form.questionings[0].id,
          op: nil,
          value: nil,
          form_id: form.id,
          questioning_id: qing.id,
          refable_qing_options: expected_ref_qing_options,
          operator_options: [{"name":"is equal to","id":"eq"},{"name":"is less than","id":"lt"},{"name":"is greater than","id":"gt"},{"name":"is less than or equal to","id":"leq"},{"name":"is greater than or equal to","id":"geq"},{"name":"is not equal to","id":"neq"}],
          value_options: nil
        }.to_json

        expect(response.body).to eq expected
      end
    end
  end
end
