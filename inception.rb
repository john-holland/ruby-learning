dreamers = ['arthur', 'saito', 'adriadne', 'cobb', 'fischer', 'eames', 'arthur', 'yusuh']
inception = {
  host: 'yusuf',
  dream: 'rain city',
  dreamers: dreamers, #yusuf is driving the van, saito gets shot like immediately :-/
  incept: {
    host: 'arthur',
    dream: 'hotel',
    dreamers: dreamers - ['yusuf'], #arthur gets in an epic slow mo fight scene
    incept: {
      host: 'eames',
      dream: 'mountain',
      dreamers: dreamers - ['yusuf', 'arthur'], #eames sets explosives, saito starts bleeding out
      incept: {
        host: 'cobb',
        dream: 'japan-limbo',
        dreamers: dreamers - ['yusuf', 'arthur', 'eames'], #ariadne takes down mal, saito falls into limbo
        incept: {
          host: 'saito',
          dream: 'final-limbo?',
          dreamers: ['saito', 'cobb'], #cobb goes looking for saito, leaves without looking at top
          incept: nil
        }
      }
    }
  }
}

# ok, bootstrapping Array#reduce with our_reduce would be an infinite loop...
def reduce(d, array, &block)
  acc = d || array.shift
  array.each { |val| acc = block.call acc, val } if array.length > 0
  acc
end

# we could do this recursively...
def we_need_to_go_deeper(inception, dreamers)
  return inception[:dreamers] unless inception[:incept]

  we_need_to_go_deeper(inception[:incept], inception[:dreamers]) if inception[:incept]
end

whos_in_limbo = we_need_to_go_deeper(inception, dreamers)
p whos_in_limbo.join ','

# OR! we could implement recursion using lambda statements!!
# ok sure but why? or rather, Y?
# enter Y combinator (a fixed point combinator),

Y = ->(gen_func) {
  ->(x) { # inceptotron, passes the lambda below that invokes the generator function
     x[x]
  }[->(x) {
    gen_func[->(*args) {
      x[x].call(*args) # call with array to get parameters
    }]
  }]
}

# our gen_func is one that can take a function that takes a param (itself), and returns a function that can take 
# return a func that takes a function that passes a function that returns a function that takes a value and nil
# call x immediately passing it to itself to achieve recursion
# now call the result of that method...

$dream_gen = ->(dream_gen) {
  ->(dreams, dream) {
    dreams << dream
    return dreams unless dream[:incept]
    dream_gen[dreams, dream[:incept]] if dream[:incept]
  }
}

# ok, but what if we wanted to escape limbo?
def our_we_need_to_go_deeper(inception)
  dreams = Y[$dream_gen][[], inception]
  dreams.last[:dreamers] # ok then
end

whos_in_limbo = our_we_need_to_go_deeper(inception)
p whos_in_limbo.join ','

# if speed is our concern, a while loop is a better alternative
# it is also nicer to the stack
def boring_we_need_to_go_deeper(inception)
  return inception[:dreamers] unless inception[:incept]
  dream = inception
  dreams = [dream]
  while dream[:incept]
    dream = dream[:incept]
    dreams << dream
  end
  dreams.last[:dreamers]
end

who_thinks_theyre_in_limbo = boring_we_need_to_go_deeper(inception)
p who_thinks_theyre_in_limbo.join ','

# what does this teach us? that closures present scoped allocation of variables
# lets us bootstrap the y combinator, and imperitive programming lets us just get it boppin'
# without thrashing the stack
def yboringer(gen_func)
  stack = []
  arg_stack = []
  push = ->(yrecurse, *args) {
    stack << yrecurse
    arg_stack << args
  }
  gen_func = gen_func.to_proc

  ->(x) {
    x[x]
  }[->(x) {
    gen_func[->(*args) {
      res = x[x, push].call(*args)
      while stack.any?
        res = stack.pop.call(*arg_stack.pop)
      end
      res
    }, push]
  }]
end

$yboringer_gen = ->(yboring_gen, push) {
  ->(push, yboring_gen, dreams, dream) {
    dreams << dream
    return dreams unless dream[:incept]
    push(->(yboring_gen, dreams, next_dream){
      yboring_gen[dreams, next_dream] if dream[:incept]
    }, yboring_gen, dreams, dream[:incept])
  }.curry[push, yboring_gen]
}

def fast_not_boring_we_need_to_go_deeper(inception)
  dreams = yboringer($yboringer_gen)[[], inception]
  dreams.last[:dreamers] # ok then
end

p fast_not_boring_we_need_to_go_deeper(inception)

concurrent_inception = {
  host: 'yusuf',
  dream: 'rain city',
  dreamers: dreamers, #yusuf is driving the van, saito gets shot like immediately :-/
  inceptions: [{
    host: 'arthur',
    dream: 'hotel',
    dreamers: dreamers - ['yusuf'], #arthur gets in an epic slow mo fight scene
    inceptions: [{
      host: 'eames',
      dream: 'mountain',
      dreamers: dreamers - ['yusuf', 'arthur'], #eames sets explosives, saito starts bleeding out
      inceptions: [{
        host: 'cobb',
        dream: 'japan-limbo',
        dreamers: dreamers - ['yusuf', 'arthur', 'eames'], #ariadne takes down mal, saito falls into limbo
        inceptions: [{
          host: 'saito',
          dream: 'final-limbo?',
          dreamers: ['saito', 'cobb'], #cobb goes looking for saito, leaves without looking at top
          incept: nil
        },
        {
          host: 'saito',
          dream: 'final-limbo?',
          dreamers: ['saito', 'cobb'], #cobb goes looking for saito, leaves without looking at top
          inceptions: [{
              host: 'saito',
              dream: 'double-final-limbo?',
              dreamers: ['saito', 'cobb'], #cobb goes looking for saito, leaves without looking at top
              inceptions: []
            }]
        }]
      }]
    }]
  }]
}

require 'parallel'
require 'concurrent'

def yboringer_threaded(gen_func)
  service = []
  stack = []
  arg_stack = []
  threads = []
  thread_args = []
  map_reduce_args = []
  push = ->(yrecurse, *args) {
    stack << yrecurse.call
    arg_stack << args
  }
  thread = ->(thread, *args) {
    threads << thread
    thread_args << args
  }
  map_reduce = ->(collection, thread_map, reduce, *args) {
    map_reduce_args << [thread_map, reduce, collection, args]
  }

  ->(x) {
    x[x]
  }[->(x) {
    gen_func[->(*args) {
      res = x[x, push, thread, map_reduce].call(*args)
      while stack.any?
        res = stack.pop.call(*arg_stack.pop)
        Parallel.each(threads) { |thread|
          thread.call(*thread_args.pop)
        } if threads.any?
        while map_reduce_args.any?
          thread_map, reduce, collection, args = map_reduce_args.pop
          res = reduce[Parallel.map(collection) { |val| thread_map.call(val, *args) }]
        end
      end
      res
    }, push, thread, map_reduce]
  }]
end

$concurrent_dream_gen = ->(dream_gen, push, thread, map_reduce) {
  ->(dreams, dream) {
    dreams << dream unless dream[:inceptions].any? # only collect the deepest dream
    return dreams unless dream[:inceptions].any?

    if dream[:inceptions].length > 1
      map_reduce(dream[:inceptions], ->(dream){
        dream_gen[dreams, dream]
      }, ->(mapped){ mapped.flat_map { |dreams| dreams } })
    else
      push(->{
        dream_gen[dreams, dream[:inceptions].last]
      })
    end
  }
}

def we_need_to_go_deeper_and_parallel_without_breaking_the_stack_bank(inception)
  dreams = Y[$concurrent_dream_gen][Concurrent::Array.new, inception]
  dreams.flat_map([]) { |dream| dream[:dreamers] }.uniq
end

we_need_to_go_deeper_and_parallel_without_breaking_the_stack_bank concurrent_inception
