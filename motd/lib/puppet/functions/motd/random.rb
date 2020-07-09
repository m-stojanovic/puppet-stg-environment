Puppet::Functions.create_function(:'motd::random') do
  dispatch :getrandom do
    param 'Integer', :max
  end

  def getrandom(max)
    rand(max)
  end
end

