// a javascript port of inception.rb
// work in progress

const dreamers = ['arthur', 'saito', 'adriadne', 'cobb', 'fischer', 'eames', 'arthur', 'yusuh']
const inception = {
  host: 'yusuf',
  dream: 'rain city',
  dreamers: dreamers, // yusuf is driving the van, saito gets shot like immediately :-/
  incept: {
    host: 'arthur',
    dream: 'hotel',
    dreamers: dreamers - ['yusuf'], // arthur gets in an epic slow mo fight scene
    incept: {
      host: 'eames',
      dream: 'mountain',
      dreamers: dreamers - ['yusuf', 'arthur'], // eames sets explosives, saito starts bleeding out
      incept: {
        host: 'cobb',
        dream: 'japan-limbo',
        dreamers: dreamers - ['yusuf', 'arthur', 'eames'], // ariadne takes down mal, saito falls into limbo
        incept: {
          host: 'saito',
          dream: 'final-limbo?',
          dreamers: ['saito', 'cobb'], // cobb goes looking for saito, leaves without looking at top
          incept: null
        }
      }
    }
  }
}

// ok, bootstrapping Array// reduce with our_reduce would be an infinite loop...
const reduce = (d, array, block) => {
  acc = d || array.shift()
  if (if array.length > 0) {
    array.forEach(val => acc = block.call(null, acc, val))
  }
  return acc
};

// we could do this recursively...
const we_need_to_go_deeper = (inception, dreamers) => {
  if (!inception?.incept) return inception?.dreamers

  if (inception?.incept) we_need_to_go_deeper(inception?.incept, inception?.dreamers)
};

const whos_in_limbo = we_need_to_go_deeper(inception, dreamers);
console.log(whos_in_limbo.join(','));

// OR! we could implement recursion using lambda statements!!
// ok sure but why? or rather, Y?
// enter Y combinator (a fixed point combinator),

const Y = (gen_func) => {
  return ((x) => x(x)) // inceptotron, passes the lambda below that invokes the generator function
     ((x) => {
        gen_func((...args) => {
          x(x).call(null, ...args) // call with array to get parameters
        })
      })
}

// our gen_func is one that can take a function that takes a param (itself), and returns a function that can take
// return a func that takes a function that passes a function that returns a function that takes a value and null
// call x immediately passing it to itself to achieve recursion
// now call the result of that method...

const $dream_gen = (dream_gen) => {
  (dreams, dream) => {
    dreams.push(dream)
    if (!dream?.incept) return dreams;
    if (dream?.incept) dream_gen(dreams, dream?.incept)
  }
}

// ok, but what if we wanted to escape limbo?
const our_we_need_to_go_deeper(inception) => {
  dreams = Y($dream_gen)([], inception)
  return dreams.last()?.dreamers; // ok then
}

const whos_in_limbo = our_we_need_to_go_deeper(inception)
console.log(whos_in_limbo.join(','));

// if speed is our concern, a while loop is a better alternative
// it is also nicer to the stack
const boring_we_need_to_go_deeper = (inception) => {
  if (!inception?.incept) return inception?.dreamers;
  let dream = inception
  const dreams = [dream]
  while (dream?.incept) {
    dream = dream?.incept
    dreams.push(dream);
  }
  return dreams.last()?.dreamers;
}

who_thinks_theyre_in_limbo = boring_we_need_to_go_deeper(inception)
console.log(who_thinks_theyre_in_limbo.join(','));

// what does this teach us? that closures present scoped allocation of variables
// lets us bootstrap the y combinator, and imperitive programming lets us just get it boppin'
// without thrashing the stack
const yboringer = (gen_func) => {
  const stack = []
  const arg_stack = []
  const push = (yrecurse, *args) => {
    stack.push(yrecurse)
    arg_stack.push(args)
  }

  return (
    (x)=>
      x(x)
    )(
      (x) => gen_func((...args) => {
        let res = x(x, push)(...args)
        while (stack.any()) {
          res = stack.pop()(...arg_stack.pop());
        }
        return res;
      }, push)
    );
}

const $yboringer_gen = (yboring_gen, push) => {
  return (push, yboring_gen, dreams, dream) => {
    dreams.push(dream)
    if (!dream?.incept) return dreams;
    return push((yboring_gen, dreams, next_dream) => {
      if (dream?.incept) yboring_gen(dreams, next_dream)
    }, yboring_gen, dreams, dream?.incept)
  }.bind(null, push, yboring_gen)
}

const fast_not_boring_we_need_to_go_deeper =(inception) => {
  dreams = yboringer($yboringer_gen)([], inception)
  return dreams.last?.dreamers // ok then
}

console.log(fast_not_boring_we_need_to_go_deeper(inception));

concurrent_inception = {
  host: 'yusuf',
  dream: 'rain city',
  dreamers: dreamers, // yusuf is driving the van, saito gets shot like immediately :-/
  inceptions: [{
    host: 'arthur',
    dream: 'hotel',
    dreamers: dreamers - ['yusuf'], // arthur gets in an epic slow mo fight scene
    inceptions: [{
      host: 'eames',
      dream: 'mountain',
      dreamers: dreamers - ['yusuf', 'arthur'], // eames sets explosives, saito starts bleeding out
      inceptions: [{
        host: 'cobb',
        dream: 'japan-limbo',
        dreamers: dreamers - ['yusuf', 'arthur', 'eames'], // ariadne takes down mal, saito falls into limbo
        inceptions: [{
          host: 'saito',
          dream: 'final-limbo?',
          dreamers: ['saito', 'cobb'], // cobb goes looking for saito, leaves without looking at top
          incept: null
        },
        {
          host: 'saito',
          dream: 'final-limbo?',
          dreamers: ['saito', 'cobb'], // cobb goes looking for saito, leaves without looking at top
          inceptions: [{
              host: 'saito',
              dream: 'double-final-limbo?',
              dreamers: ['saito', 'cobb'], // cobb goes looking for saito, leaves without looking at top
              inceptions: []
            }]
        }]
      }]
    }]
  }]
}

// TODO: find node parallelism library to swap in
// TODO: switch to lodash or underscore
require 'parallel'
require 'concurrent'

const yboringer_threaded(gen_func) => {
  const service = []
  const stack = []
  const arg_stack = []
  const threads = []
  const thread_args = []
  const map_reduce_args = []
  const push = (yrecurse, ...args) => {
    stack.push(yrecurse())
    arg_stack.push(args)
  }
  const thread = (thread, *args) => {
    threads.push(thread)
    thread_args.push(args)
  }
  const map_reduce = (collection, thread_map, reduce, *args) => {
    map_reduce_args.push([thread_map, reduce, collection, args])
  }

  return ((x) => {
    x(x)
  })((x) => {
    gen_func((...args) => {
      let res = x(x, push, thread, map_reduce)(...args)
      while (stack.any()) {
        res = stack.pop()(...arg_stack.pop())
        if (threads.any()) Parallel.forEach(threads, (thread) => {
          thread(...thread_args.pop())
        });
        while (map_reduce_args.any())
          const [thread_map, reduce, collection, args] = map_reduce_args.pop()
          res = reduce(Parallel.map(collection, val => thread_map(val, ...args)))
        }
      }
      return res
    }, push, thread, map_reduce)
  });
}

const $concurrent_dream_gen = (dream_gen, push, thread, map_reduce) => {
  return (dreams, dream) => {
    if (!dream?.inceptions.any()) dreams.push(dream) // only collect the deepest dream
    if (!dream?.inceptions.any()) return dreams

    if (dream?.inceptions.length > 1) {
      return map_reduce(
        dream?.inceptions,
        (dream) => dream_gen(dreams, dream,
        (mapped) => mapped.flat_map(dreams => dreams)
      )
    } else {
      return push(() => {
        dream_gen(dreams, dream?.inceptions.last())
      })
    }
  }
}

const we_need_to_go_deeper_and_parallel_without_breaking_the_stack_bank = (inception) => {
  const dreams = Y($concurrent_dream_gen)(Concurrent::Array.new, inception) // TODO: what is the javascript equivelent?
  return dreams.flat_map(dream => dream?.dreamers).uniq()
}

console.log(we_need_to_go_deeper_and_parallel_without_breaking_the_stack_bank(concurrent_inception))
