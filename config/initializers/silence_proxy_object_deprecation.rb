# Silence ActiveSupport::ProxyObject deprecation warnings
# This is needed temporarily for gems like 'roo' that haven't been updated
# to use Ruby's BasicObject instead of ActiveSupport::ProxyObject

if Rails.env.development?
  # Capture the original warn method
  original_warn_method = ActiveSupport::Deprecation.method(:warn)
  
  # Override the warn method to filter out specific warnings
  ActiveSupport::Deprecation.define_singleton_method(:warn) do |message, callstack = nil, deprecation_horizon = nil|
    # Skip the ActiveSupport::ProxyObject deprecation warning
    unless message.include?("ActiveSupport::ProxyObject is deprecated")
      original_warn_method.call(message, callstack, deprecation_horizon)
    end
  end
end
