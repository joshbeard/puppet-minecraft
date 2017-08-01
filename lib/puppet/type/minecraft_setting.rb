Puppet::Type.newtype(:minecraft_setting) do
  @doc = 'Manages minecraft settings which are written to JSON files but modified via server commands.'

  newproperty(:value, :array_matching => :all) do
    desc 'The array of values for this setting'

    def insync?(is)
      is.sort == should.sort
    end
  end

  newparam(:filename, namevar: true) do
    desc 'The .json file with the current setting value'
  end

  newparam(:id_property) do
    desc 'The property in the JSON file which the "value" property should match'
  end

  newparam(:add_command) do
    desc 'The command to run to add an item to the JSON file, parameterised with %s'
  end

  newparam(:remove_command) do
    desc 'The command to run to remove an item to the JSON file, parameterised with %s'
  end

  newparam(:user) do
    desc 'The user minecraft runs as'
  end

  newparam(:instance) do
    desc 'The minecraft instance to manage'
  end
end
