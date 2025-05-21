# app/policies/incident_entry_policy.rb
class IncidentEntryPolicy < MembershipBasedPolicy
  def create?
    same_organization? && editor?
  end

  private

  def subject_page
    record.incident.status_page
  end

  def subject_organization_id
    record.incident.status_page.organization_id
  end
end
