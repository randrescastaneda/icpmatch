*! V0.1  <Andres Castaneda>  <19Jun2017>
/*====================================================================
project:       ICP Labels
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:    19 Jun 2017 - 12:45
Modification Date:   
Do-file version:    01
References:          
Output:             dta file
====================================================================*/

cap drop program icpmatch_labels
	program define icpmatch_labels
		args varname
		
		label define icplabels ///
		11010109 "_UNBR Food and non-alcoholic beverages"	///
		11011009 "_UNBR Food"  ///
		11011101 "Rice"  ///
		11011102 "Other cereals, flour and other products"  ///
		11011103 "Bread"  ///
		11011104 "Other bakery products"  ///
		11011105 "Pasta products"  ///
		11011109 "_UNBR Bread and cereals"  ///
		11011201 "Beef and veal"  ///
		11011202 "Pork"  ///
		11011203 "Lamb, mutton and goat"  ///
		11011204 "Poultry"  ///
		11011205 "Other meats and meat preparations"  ///
		11011209 "_UNBR Meat"  ///
		11011301 "Fresh, chilled or frozen fish and seafood"  ///
		11011302 "Preserved or processed fish and seafood"  ///
		11011309 "_UNBR Fish and seafood"  ///
		11011401 "Fresh milk"  ///
		11011402 "Preserved milk and other milk products"  ///
		11011403 "Cheese"  ///
		11011404 "Eggs and egg-based products"  ///
		11011409 "_UNBR Milk, cheese and eggs"  ///
		11011501 "Butter and margarine"  ///
		11011503 "Other edible oil and fats"  ///
		11011509 "_UNBR Oils and fats"  ///
		11011601 "Fresh or chilled fruits"  ///
		11011602 "Frozen, preserved or processed fruit and fruit-based products"  ///
		11011609 "_UNBR Fruits"  ///
		11011701 "Fresh or chilled vegetables other than potatoes"  ///
		11011702 "Fresh or chilled potatoes"  ///
		11011703 "Frozen, preserved or processed vegetables and vegetable-based products"  ///
		11011709 "_UNBR Vegetables"  ///
		11011801 "Sugar"  ///
		11011802 "Jams, marmalades and honey"  ///
		11011803 "Confectionery, chocolate and ice cream"  ///
		11011809 "_UNBR Sugar, jam, honey, chocolate and confectionery"  ///
		11011901 "Food products n.e.c."  ///
		11012009 "_UNBR Non-alcoholic beverages"  ///
		11012101 "Coffee, tea and cocoa"  ///
		11012201 "Mineral waters, soft drinks, fruit and vegetable juices"  ///
		11020109 "_UNBR Alcoholic beverages, tobacco and narcotics"  ///
		11021009 "_UNBR Alcoholic beverages"  ///
		11021101 "Spirits"  ///
		11021201 "Wine"  ///
		11021301 "Beer"  ///
		11022101 "Tobacco"  ///
		11023101 "Narcotics"  ///
		11030109 "_UNBR Clothing and footwear"  ///
		11031009 "_UNBR Clothing"  ///
		11031101 "Clothing material, other articles of clothing and clothing accessories"  ///
		11031201 "Garments"  ///
		11031401 "Cleaning, repair and hire of clothing"  ///
		11032009 "_UNBR Footwear"  ///
		11032101 "Shoes and other footwear"  ///
		11032201 "Repair and hire of footwear"  ///
		11040109 "_UNBR Housing, water, electricity, gas and other fuels"  ///
		11041101 "Actual and imputed rentals for housing"  ///
		11043101 "Maintenance and repair of the dwelling"  ///
		11044009 "_UNBR Water supply and miscellaneous services relating to the dwelling"  ///
		11044101 "Water supply"  ///
		11044201 "Miscellaneous services relating to the dwelling"  ///
		11045009 "_UNBR Electricity, gas and other fuels"  ///
		11045101 "Electricity"  ///
		11045201 "Gas"  ///
		11045301 "Other fuels"  ///
		11050109 "_UNBR Furnishing, household equipment and routine household maintenance"  ///
		11051009 "_UNBR Furniture and furnishings, carpets and other floor coverings"  ///
		11051101 "Furniture and furnishings"  ///
		11051201 "Carpets and other floor coverings"  ///
		11051301 "Repair of furniture, furnishings and floor coverings"  ///
		11052101 "Household textiles"  ///
		11053009 "_UNBR Household appliances"  ///
		11053101 "Major household appliances whether electric or not"  ///
		11053201 "Small electric household appliances"  ///
		11053301 "Repair of household appliances"  ///
		11054101 "Glassware, tableware and household utensils"  ///
		11055009 "_UNBR Tools and equipment for house and garden"  ///
		11055101 "Major tools and equipment"  ///
		11055201 "Small tools and miscellaneous accessories"  ///
		11056009 "_UNBR Goods and services for routine household maintenance"  ///
		11056101 "Non-durable household goods"  ///
		11056201 "Domestic services"  ///
		11056202 "Household services"  ///
		11056209 "_UNBR Domestic services and household services"  ///
		11060109 "_UNBR Health"  ///
		11061009 "_UNBR Medical products, appliances and equipment"  ///
		11061101 "Pharmaceuticals products"  ///
		11061201 "Other medical products"  ///
		11061301 "Therapeutic appliances and equipment"  ///
		11062009 "_UNBR Out-patient services"  ///
		11062101 "Medical services"  ///
		11062201 "Dental services"  ///
		11062301 "Paramedical services"  ///
		11063101 "Hospital services"  ///
		11064009 "_UNBR Out-patient and hospital services"  ///
		11070109 "_UNBR Transport"  ///
		11071009 "_UNBR Purchase of vehicles"  ///
		11071101 "Motor cars"  ///
		11071201 "Motor cycles"  ///
		11071301 "Bicycles"  ///
		11071401 "Animal drawn vehicles"  ///
		11072009 "_UNBR Operation of personal transport equipment"  ///
		11072201 "Fuels and lubricants for personal transport equipment"  ///
		11072301 "Maintenance and repair of personal transport equipment"  ///
		11072401 "Other services in respect of personal transport equipment"  ///
		11073009 "_UNBR Transport services"  ///
		11073101 "Passenger transport by railway"  ///
		11073201 "Passenger transport by road"  ///
		11073301 "Passenger transport by air"  ///
		11073401 "Passenger transport by sea and inland waterway"  ///
		11073501 "Combined passenger transport"  ///
		11073601 "Other purchase transport services"  ///
		11080109 "_UNBR Communication"  ///
		11081101 "Postal services"  ///
		11082101 "Telephone and telefax equipment"  ///
		11083101 "Telephone and telefax services"  ///
		11090109 "_UNBR Recreation and culture"  ///
		11091009 "_UNBR Audio-visual, photographic and information processing equipment"  ///
		11091101 "Audio-visual, photographic and information processing equipment"  ///
		11091401 "Recording media"  ///
		11091501 "Repair of audio-visual, photographic and information process. equipment"  ///
		11092009 "_UNBR Other major durables for recreation and culture"  ///
		11092101 "Major durables for outdoor and indoor recreation"  ///
		11092301 "Maintenance and repair of other major durables for recreation and culture"  ///
		11093009 "_UNBR Other recreational items and equipment, garden and pets"  ///
		11093101 "Other recreational items and equipment"  ///
		11093301 "Garden and pets"  ///
		11093501 "Veterinary and other services for pets"  ///
		11094009 "_UNBR Recreational and cultural services"  ///
		11094101 "Recreational and sporting services"  ///
		11094201 "Cultural services"  ///
		11094301 "Games of chance"  ///
		11095101 "Newspapers, books and stationery"  ///
		11096101 "Package holidays"  ///
		11101101 "Education"  ///
		11111101 "Catering services"  ///
		11112101 "Accommodation services"  ///
		11120109 "_UNBR Miscellaneous goods and services"  ///
		11121009 "_UNBR Personal care"  ///
		11121101 "Hairdressing salons and personal grooming establishments"  ///
		11121201 "Appliances, articles and products for personal care"  ///
		11122101 "Prostitution"  ///
		11123009 "_UNBR Personal effects n.e.c."  ///
		11123101 "Jewellery, clocks and watches"  ///
		11123201 "Other personal effects"  ///
		11124101 "Social protection"  ///
		11125101 "Insurance"  ///
		11126009 "_UNBR Financial services n.e.c."  ///
		11126101 "FISIM"  ///
		11126201 "Other financial services n.e.c."  ///
		11127101 "Other services n.e.c."  ///
		11131101 "Purchases by residential households in the rest of the world"  ///
		11131102 "Purchases by non-residential households in the economic territory of the country", ///
		modify
		
		label values `varname' icplabels
	end

	exit 
