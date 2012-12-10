method_to_enable = [:normal, :def_init, :initializer, :better_init][3]

if method_to_enable == :normal
	# the normal, redundant way to do it
	class Person
		def initialize(name, age, gender=:male, friends=["John", "Bob"])
			@name = name
			@age = age
			@gender = gender
			@best_friend = friends.first
			yield "I’m alive!"
		end
	end
end

if method_to_enable == :better_init
	# my attempt at improvement – currently unfinished
	# will allow default values, and arguments to be passed to the block
	# block arguments will be allowed to mix with normal arguments,
	# to allow both types to have default values
	# do I need to do more to allow a block to be passed to SomeClass.new ?
	# might not be called better_init when it’s done
	class Class
		def better_init(*args, &b)
			num_other_args = b.arity
			define_method(:__init_proc) {b}
			params = args.join(", ")
			vars = args.collect{|a| "@#{a}"}.join(", ")
		
			class_eval <<-EOS
	def initialize(#{params})
		#{vars} = #{params}
		instance_eval &__init_proc
	end
			EOS
		end
	end
	class Person
		better_init(:name, :age, :gender) do |friends=["John", "Bob"]|
			@best_friend = friends.first
			yield "I’m alive!"
		end
	end
end


if method_to_enable == :def_init
	# def_init:
	# http://redsquirrel.com/cgi-bin/dave/2006/07/index.html
	class Class
		def def_init(*attrs)
			constructor = "def initialize("
			constructor << attrs.map{|a| a.to_s}.join(",")
			constructor << ")\n"
			attrs.each do |attribute|
				constructor << "@#{attribute} = #{attribute}\n"
			end
			constructor << "end"
			class_eval(constructor)
		end
	end
	class Person
		def_init :name, :age, :gender
	end
end

if method_to_enable == :initializer
	# initializer:
	# http://c2.com/cgi/wiki?PythonRubyInitializer
	# initializer (current best)
	class Class
		def initializer(*args, &b)
			define_method(:__init_proc) {b}
			params = args.join(", ")
			vars = args.collect{|a| "@#{a}"}.join(", ")
		
			class_eval <<-EOS
	def initialize(#{params})
		#{vars} = #{params}
		instance_eval &__init_proc
	end
			EOS
		end	
	end
	class Person
		initializer(:name, :age, :gender) do
			puts "Do more initialization for #{@name}"
		end
	end
end

# testing code
class Person
	attr_reader :name, :gender
	attr_accessor :age
	
	def to_s
		"Person: " + [@name, @age, @gender].join(", ")
	end
end
me = Person.new("Rory", 19, :male) if [:def_init, :initializer].include?(method_to_enable)
if [:normal, :better_init].include?(method_to_enable)
	me = Person.new("Rory", 19) do |message|
		puts "NAME says “#{message}”"
	end
end
puts me