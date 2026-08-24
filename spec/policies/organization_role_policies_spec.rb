require "rails_helper"

RSpec.describe "organization-level authorization" do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let(:admin) { create(:user, :admin, organization: organization) }
  let(:member) { create(:user, :member, organization: organization) }
  let(:other_admin) { create(:user, :admin, organization: other_organization) }
  let!(:status_page) { create(:status_page, organization: organization) }
  let!(:other_status_page) { create(:status_page, organization: other_organization) }
  let(:incident) { Incident.new(status_page: status_page) }
  let(:other_incident) { Incident.new(status_page: other_status_page) }
  let(:incident_entry) { IncidentEntry.new(incident: incident) }

  it "allows every organization member to list and view that organization's status pages" do
    expect(StatusPagePolicy.new(member, status_page).show?).to be(true)
    expect(StatusPagePolicy::Scope.new(member, StatusPage).resolve).to contain_exactly(status_page)
  end

  it "allows only organization admins to manage status pages" do
    expect([ :create?, :update?, :destroy? ]).to all(satisfy { |action| StatusPagePolicy.new(admin, status_page).public_send(action) })
    expect([ :create?, :update?, :destroy? ]).to all(satisfy { |action| !StatusPagePolicy.new(member, status_page).public_send(action) })
  end

  it "allows members to view incidents but only admins to change incidents and entries" do
    expect(IncidentPolicy.new(member, incident).show?).to be(true)
    expect([ :create?, :update?, :destroy? ]).to all(satisfy { |action| !IncidentPolicy.new(member, incident).public_send(action) })
    expect([ :create?, :update?, :destroy? ]).to all(satisfy { |action| !IncidentEntryPolicy.new(member, incident_entry).public_send(action) })
    expect([ :create?, :update?, :destroy? ]).to all(satisfy { |action| IncidentPolicy.new(admin, incident).public_send(action) })
    expect([ :create?, :update?, :destroy? ]).to all(satisfy { |action| IncidentEntryPolicy.new(admin, incident_entry).public_send(action) })
  end

  it "never permits access across organizations" do
    expect([ :show?, :create?, :update?, :destroy? ]).to all(satisfy { |action| !StatusPagePolicy.new(admin, other_status_page).public_send(action) })
    expect([ :show?, :create?, :update?, :destroy? ]).to all(satisfy { |action| !IncidentPolicy.new(admin, other_incident).public_send(action) })
  end
end
