require 'plist'
require 'FileUtils'

class Command
	attr_accessor :name
	attr_accessor :commands
	attr_accessor :oneliner
	attr_accessor :keys

	def initialize (name, commands, keys)
  	@name = name
  	@commands = commands
  	@oneliner = commands.join(', ')
  	@keys = keys
	end
end

def duplicate_keys
	'@d'
end

def duplicate_name
	'Duplicate current line'
end

def duplicate_instr
	[
	'selectLine:',
	'copy:',
	'moveToEndOfLine:',
	'insertNewline:',
	'paste:',
	'deleteBackward:'
	]
end

def delete_keys
	'$@D'
end

def delete_name
	'Delete current line'
end

def delete_instr
	[
		'selectLine:',
		'deleteBackward:',
		'moveToEndOfLine:'
	]
end

def commands_array
	[
		Command.new(duplicate_name, duplicate_instr, duplicate_keys),
		Command.new(delete_name, delete_instr, delete_keys)
	]
end

def customized_key_bindings
	commands = {}
	commands_array.each do |command|
		commands[command.name] = command.oneliner
	end

	{
		"Customized" => commands
	}
end

def possible_bindingds_plist_path
	'/Applications/Xcode.app/Contents/Frameworks/IDEKit.framework/Resources/IDETextKeyBindingSet.plist'
end

def used_bindings_plist_path
	File.join(ENV['HOME'], '/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings')
end

def create_key_bindings(plist_path)
	slave = Plist.parse_xml(plist_path)
	master = customized_key_bindings
	keys = slave.merge(master)

	File.open(plist_path, 'wb') do |f|
	  f.puts(keys.to_plist('    '))
	end
end

def set_keys(plist_path)
	raise "No idekeybindings file found" unless File.exists?(plist_path)
	plist_path_appended = "#{plist_path}.plist"
	File.rename(plist_path, plist_path_appended)
	bindings = Plist.parse_xml(plist_path_appended)
	raise "Bindings not found" unless bindings.nil? == false
	key_meta = 'Text Key Bindings'
	key_bindings = 'Key Bindings'
	text_key_bindings_meta = bindings[key_meta]
	text_key_bindings = text_key_bindings_meta[key_bindings]
	commands_array.each do |command|
		text_key_bindings[command.keys] = command.commands
	end
	text_key_bindings_meta[key_bindings] = text_key_bindings
	bindings[key_meta] = text_key_bindings_meta

	File.open(plist_path_appended, 'wb') do |f|
	  f.puts(bindings.to_plist('    '))
	end

	FileUtils.mv(plist_path_appended, plist_path)
end

create_key_bindings(possible_bindingds_plist_path)
set_keys(used_bindings_plist_path)