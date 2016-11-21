class ApiConstraints
  attr_reader :version, :default

  def initialize(options)
    @version = options.fetch(:version, nil)
    @default = options.fetch(:default, nil)
  end

  def matches?(req)
    default || req.headers['Accept'].include?("application/vnd.rails-auth.v#{version}")
  end
end
