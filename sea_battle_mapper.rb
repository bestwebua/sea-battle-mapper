=begin
Sea Battle Mapper by Vladislav Trotsenko.

I wanna say hello to Vertalab&RubyForce. Who else showed
so much creativity and was ignored like me?))) In any case, it was
a useful experience.

Write a method that will check out ships coords and print out them as a map.
Your fleet should consist: 1 of four-deck, 2 of three-deck, 3 of two-deck and
4 of single-deck ships.

Coordinates should be in a range a-j and 1-10.
=end

def sea_battle_mapper(locations)
  coords = locations.scan(/\w+/)
  error1, error2, error3 = ['You have incorrect coordinates!',
                      "Your fleet is not completed or have wrong amount of ships.",
                      "For one or more ships your coordinates isn't unique!"
                      ]

  abort error1 unless coords.all? { |coord| coord[/\A([a-j]([1-9]|10)){1,4}\z/i] }

  fleet = {}
  (1..4).reverse_each { |item| fleet[item] = [] }
    coords.each { |coord| fleet[coord.delete('0-9').size] << coord }
      type_test, total_test = 4, 1
        fleet.each do |type, total|
          abort error2 if [type, total.size] != [type_test, total_test]
          type_test-=1; total_test+=1
        end

  map_points, stack = [], []
  locations.scan(/[a-j]{1}|\d+/i)
    .map { |char| char =~ /\d/ ? char.to_i : char.downcase }
      .each.with_index do |char, index|
          stack << char
        map_points << stack.clone and stack.clear if index.odd?
      end

  abort error3 unless map_points == map_points.uniq

  map, coords_row, white, black = [], ('a'..'j').to_a, "\u2B1C", "\u2B1B"
  coords_column = (0..10).to_a.map { |number| number < 10 ? ' ' + number.to_s : number.to_s }
    map << coords_row and 10.times { map << [white]*10 }
      map_points.each do |point|
        letters, numbers = point
          map[numbers][coords_row.index(letters)] = black
      end
    map.map.with_index { |item, index| index.zero? ? item.unshift('  ') : item.unshift(coords_column[index]) }
  puts map.map { |item| item.join(' ') }.join("\n")

end

class RandomShips
  def self.new
    objects_to_create, objects, spaces_coords = {4 => 1, 3 => 2, 2 => 3, 1 => 4}, [], []
    #Let's create our coords dictionary on a place. I'm use 12x12 matrix instead 10x10 for exclude going beyond the coordinates
    #Hell yeah, .each_with_object is realy cool stuff!
      dict = (0..11).each_with_object({}) do |number, hash|
        hash[number] = [] and ('a'..'k').to_a.unshift('x').each { |letter| hash[number] << letter + number.to_s }
      end
    number = f_number = letter_number = f_letter_number = 0
      until objects_to_create.empty? #Creating ships by our hash table
        ship_type, position = objects_to_create.max[0], ['horizontal', 'vertical'] #Let's do it from larger to smaller type
          loop do
            case position.sample
              when 'horizontal'
                number, f_letter_number = rand(1..10), rand(1...10-ship_type)
                  l_letter_number = f_letter_number + ship_type
                    coords_range = dict[number][f_letter_number...l_letter_number] #horizontal ship prototype
                    top_space = dict[number-1][f_letter_number-1..l_letter_number] #space border like margin, top
                  bottom_space = dict[number+1][f_letter_number-1..l_letter_number] #bottom
                left_space, right_space = dict[number][f_letter_number-1], dict[number][l_letter_number] #left & right
              else
                f_number, letter_number = rand(1...10-ship_type), rand(1..10)
                  l_number = f_number + ship_type
                    coords_range = (dict[f_number][letter_number]...dict[l_number][letter_number]).to_a #vertical ship prototype
                    top_space, bottom_space = dict[f_number-1][letter_number], dict[l_number][letter_number] #space border like margin, top & bottom
                  left_space = (dict[f_number-1][letter_number-1]..dict[l_number][letter_number-1]).to_a #left
                right_space = (dict[f_number-1][letter_number+1]..dict[l_number][letter_number+1]).to_a #right
            end
              #Collecting free space around the ship and adding unique space coords only
              [top_space, bottom_space, left_space, right_space].each do |coord| 
                spaces_coords << coord unless spaces_coords.flatten.include?(coord)
              end
                valid_ship = coords_range.none? { |coord| objects.flatten.include?(coord) } #Is a ship is unique?
              valid_space = coords_range.none? { |coord| spaces_coords.flatten.include?(coord) } #Is the border clear?
            #Add our ship prototype and exit from the loop, otherwise clean space coords and repeat the loop
            valid_ship && valid_space ? (objects << coords_range and break) : spaces_coords.pop
          end
        objects_to_create[ship_type]-=1 #Reducing ships amount
      objects_to_create.delete_if { |k,v| v.zero? } #And clean up the hash from the ships that we created 
    end
    objects.map(&:join).join(', ') #Yup, our test string with ships coords is ready!
  end
end

sea_battle_mapper(RandomShips.new)