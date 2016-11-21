require 'spec_helper'

describe ApiConstraints do
  before do
    @api_constraints_v1 = ApiConstraints.new(version: 1)
    @api_constraints_v2 = ApiConstraints.new(version: 2, default: true)
  end

  describe '#matches?' do
    it 'returns true when the version matches the \'Accept\' header' do
      request = double(host: 'api.rails-auth.dev',
                       headers: {'Accept' => 'application/vnd.rails-auth.v1'})

      expect(@api_constraints_v1.matches?(request)).to eq(true)
    end

    it 'returns the default version when \'default\' option is specified' do
      request = double(host: 'api.rails-auth.dev')
      expect(@api_constraints_v2.matches?(request)).to eq(true)
    end
  end
end
