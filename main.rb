def tag(tagname, self_close=true)
  define_method(tagname) do |attributes={}, &block|
    markup = "<#{tagname}" + (attributes.empty? ? '' : ' ') + attributes.map { |k,v| "#{k}=\"#{v}\"" }.join(' ') + (block ? ">\n" : '')
    # accepting a block and using the call method is the same as calling yield
    #  with the exception that block is considered a parameter of the current block
    #  and thus doesn't mess with enumeration ... weird and cool!
    if block
      bv = block.call
      markup += if bv.kind_of?(Array)
                  bv.join('\n')
                else
                  bv
                end
    end
  ensure
    markup += block ? "</#{tagname}>\n" : ' />\n'
    return markup
  end
end

tag('div')
tag('p')
tag('href')
tag('input', self_close=true)

url = 'google.com'
markup = div :name => 'test' do
  p do
    [(href :src => url do 'test' end),
     (input :type => 'text'),
     (input :type => 'button', :value => 'press me!')]
  end
end

puts markup
