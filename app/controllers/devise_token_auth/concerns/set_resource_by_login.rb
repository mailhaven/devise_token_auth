module DeviseTokenAuth::Concerns::SetResourceByLogin
  extend ActiveSupport::Concern

  protected
  
  def set_resource(field=nil)
    # Check
    field ||= authentication_key_field()

    @resource = nil
    if field
      q_value = resource_params[field]

      if resource_class.case_insensitive_keys.include?(field)
        q_value.downcase!
      end

      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        q = "#{field.to_s} = ? AND provider='#{default_provider}'"
        q = "BINARY " + q
        @resource = resource_class.where(q, q_value).first
      else
        @resource = resource_class.where(provider: default_provider).
                    find_for_database_authentication(login: q_value)
      end
    end
  end

  private

  def authentication_key_field
    key_params = resource_class.authentication_keys
    key_params = key_params.keys if key_params.is_a?(Hash)
    key_field  = (resource_params.keys.map(&:to_sym) & key_params).first

    return key_field
  end

  def default_provider
    return 'email'
  end

end

