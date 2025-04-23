class ProductPolicy < ApplicationPolicy
  def show?
    viewer_or_editor?
  end

  def update?
    editor?
  end

  def destroy?
    editor?
  end

  def regenerate_static?
    editor?
  end

  private

  def viewer_or_editor?
    membership.present?
  end

  def editor?
    membership&.role == "editor"
  end

  def membership
    @membership ||= Membership.find_by(user: user, product: record)
  end
end
