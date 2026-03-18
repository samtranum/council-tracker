class SiteSettingPolicy < ApplicationPolicy
  # Site settings are platform-wide, super admins only
  def edit?
    admin?
  end

  def update?
    admin?
  end
end
