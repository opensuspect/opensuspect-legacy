## Use descriptive variable names
### Bad
    func computerTime(d):
### Good
    func computeTime(daysElapsed):
## Be consistent
### Bad
    obj.fetch()
    thing.Get()
### Good
    obj.get()
    thing.get()

## The first word in a function name should be a verb, in a class it should be a noun
### Bad
    timerIncrement()
### Good
    incrementTimer()

## Avoid vague comments
### Bad
    # TODO
    setTime()
### Good
    # TODO: add timezones
    setTime()

## Avoid excessive elif
### Bad
````
if (a ==1):
   doSomething()
elif (a == 2)
  doSomethingElse()
elif (a ==3)
  doYetAnotherThing()
else
  doDefaultThing()
````
### Good
````
match a:
  1: 
    doSomething()
  2:
    doSomethingElse()
  3:
   doYetAnotherThing()
 _:
   doDefaultThing()
````
## Avoid deep nesting
### Bad
````
if objectExists():
    if objectIsGreen():
        if objectIsMoving():
            return true
        else:
            return false
    else:
        return false
else:
    return false
````
### Good
````
if not objectExists():
    return false
if not objectIsGreen():
    return false
if not objectIsMoving():
    return false
return true
````
## Avoid horizontally long code
### Bad
    var colors = {1: "green", 2: "red", 3: "orange", 4: "purple"}
### Good
```
var colors = {}
colors[1] = "green"
colors[2] = "red"
colors[3] = "orange"
colors[4] = "purple"
```

## Obey the Law of Demeter
### Bad
    Players[i].player.inventory += item
### Good
    Players[current].AddInventoryItem(item)

## Break long functions up
### Bad
````
func doSomethingComplex:
  # Setup
  [ 30 lines of code ]
  # Process
  [ 60 lines of code ]
  # Cleanup
  [ 20 lines of code ]
````
### Good
````
func doSomethingComplex:
  var values = setup()
  process(values)
  cleanup()
````
## Keep code DRY (don't repeat yourself)
### Bad
````
  process(obj1)
  process(obj2)
  process(obj3)
````
### Good
    for obj in [obj1, obj2, obj3]:
      process(obj)
