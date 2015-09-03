
//Both count as failures, and they don't equate to each other
//this lets us do if(Pop()) without having to specifically check for underflow
//same for if(Push()) and overflow
#define STACK_OVERFLOW	-1
#define STACK_UNDERFLOW	-2


/datum/stack
	var/list/stack = list()
	var/max_elements = 0

/datum/stack/New(list/elements,max)
	..()
	if(elements)
		stack = elements.Copy()
	if(max)
		max_elements = max

/datum/stack/proc/Pop()
	if(is_empty())
		return STACK_UNDERFLOW
	. = stack[stack.len]
	stack.Cut(stack.len,0)

/datum/stack/proc/Push(element)
	if(max_elements && (stack.len+1 > max_elements))
		return STACK_OVERFLOW
	stack += element

/datum/stack/proc/Top()
	if(is_empty())
		return STACK_UNDERFLOW
	. = stack[stack.len]

/datum/stack/proc/is_empty()
	. = (stack.len > 0)

//Rotate entire stack left with the leftmost looping around to the right
/datum/stack/proc/RotateLeft()
	if(is_empty())
		return 0
	. = stack[1]
	stack.Cut(1,2)
	Push(.)

//Rotate entire stack to the right with the rightmost looping around to the left
/datum/stack/proc/RotateRight()
	if(is_empty())
		return 0
	. = stack[stack.len]
	stack.Cut(stack.len,0)
	stack.Insert(1,.)


/datum/stack/proc/Copy()
	var/datum/stack/S=new()
	S.stack = stack.Copy()
	S.max_elements = max_elements
	return S


/datum/stack/proc/Clear()
	stack.Cut()
