
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIZZA!!!////////////////////////////////////////////////

/datum/table_recipe/margheritapizza
	name = "Margherita pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 4,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/margherita
	category = CAT_FOOD

/datum/table_recipe/meatpizza
	name = "Meat pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/meat/cutlet = 4,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/meat
	category = CAT_FOOD

/datum/table_recipe/mushroompizza
	name = "Mushroom pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom = 5
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/mushroom
	category = CAT_FOOD

/datum/table_recipe/vegetablepizza
	name = "Vegetable pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/vegetable
	category = CAT_FOOD

/datum/table_recipe/donpocketpizza
	name = "Donkpocket pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/donkpocket/warm = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/donkpocket
	category = CAT_FOOD

/datum/table_recipe/dankpizza
	name = "Dank pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/dank
	category = CAT_FOOD

/datum/table_recipe/sassysagepizza
	name = "Sassysage pizza"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 3,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pizza/sassysage
	category = CAT_FOOD