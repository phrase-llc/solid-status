class MembershipBasedPolicy < ApplicationPolicy
  private

  def same_organization?
    subject_organization_id == user.organization_id
  end

  def admin?
    user.admin?
  end

  def editor?
    return true if admin?
    Membership.exists?(user: user, page: subject_page, role: "editor")
  end

  def viewer?
    return true if admin?
    Membership.exists?(user: user, page: subject_page)
  end

  # この2つは各Policyでオーバーライドする
  def subject_page
    raise NotImplementedError
  end

  def subject_organization_id
    raise NotImplementedError
  end
end
