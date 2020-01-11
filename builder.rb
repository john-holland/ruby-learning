class Builder
  def initialize(**property_map, &build)
    @property_map = property_map
    property_map.keys.each { |property| add_property(property) { property_map[property] } }
    @build = build
  end

  def add_property(name, &block)
    @property_map[name] = block.call self

    define_singleton_method("#{name}=".to_sym) do |val|
      @property_map[name] = val
    end

    define_singleton_method(name.to_sym) do |*args|
      @property_map[name] = args[0] if args.length == 1
      return @property_map[name] if args.length == 0

      Builder.new(@property_map, &@build)
    end
  end

  def build(&build)
    (build || @build).call @property_map
  end
end

class Car
  def initialize(color: 'green', horse_power: '300', ticket_chance: 20)
    @color = color
    @horse_power = horse_power
    @ticket_chance = ticket_chance
  end
end

pp car = Builder.new(color: 'no color!?',
                     horse_power: 300,
                     ticket_chance: 5) { |args|
                       Car.new(**args)
                     }
car.color = 'red' #mutable!
pp car
new_car = car.color('aqua') #immutable!

puts "immutable!!" unless new_car == car #immutable!!!

pp new_car.build { |args| Car.new(**args) }
