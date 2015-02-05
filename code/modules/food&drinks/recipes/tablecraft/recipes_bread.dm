
// see code/datums/recipe.dm

////////////////////////////////////////////////BREAD////////////////////////////////////////////////

/datum/table_recipe/bread/meat
	name = "Meat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/meat

/datum/table_recipe/bread/xenomeat
	name = "Xenomeat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/xenomeat

/datum/table_recipe/bread/spidermeat
	name = "Spidermeat bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/spidermeat = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/spidermeat

/datum/table_recipe/bread/banana
	name = "Banana nut bread"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/banana

/datum/table_recipe/bread/tofu
	name = "Tofu bread"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/tofu = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 3
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/tofu

/datum/table_recipe/bread/creamcheese
	name = "Cream cheese bread"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/bread/creamcheese

