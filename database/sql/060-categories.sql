/************************************************************************************************************
categories
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS categories
(
  id serial PRIMARY KEY,
  category_id citext,
  category citext not null,
  subcategory citext
);

--
CREATE UNIQUE INDEX categories_uidx ON categories(category, subcategory, source);;
-- unique index to not allow more than one null on subcategory
CREATE UNIQUE INDEX categories_null_uidx ON categories (source, category, (subcategory IS NULL)) WHERE subcategory IS NULL;


CREATE TABLE IF NOT EXISTS user_categories
(
  id SERIAL PRIMARY KEY,
  user_id integer references users(id) on delete cascade on update cascade,
  user_category citext,
  user_subcategory citext,
  min_budgeted_amount numeric(28,10) default 0,
  max_budgeted_amount numeric(28,10) default 0,
  do_not_budget boolean default false
);
-- unique index to not allow more than one null on user_subcategory
create unique index user_categories_uidx  on user_categories (user_id, user_category, (user_subcategory is null)) WHERE user_subcategory is null;
create unique index user_categories_uidx2 on user_categories (user_id, user_category, user_subcategory);  

create or replace function user_category_update_values() returns trigger AS $$
  begin

	update transactions t
		   set category = subquery.user_category,
			   subcategory = subquery.user_subcategory
	  from (select c.category, c.subcategory, uc.user_category, uc.user_subcategory
			  from user_categories uc
			 inner join categories c on c.id = category_id
			 where user_id = new.user_id
			   and category_id = new.category_id) subquery
	 where t.imported_category = subquery.category
	   and t.imported_subcategory = subquery.subcategory;   
	   
    return new;
  end
$$ LANGUAGE plpgsql;

create or replace trigger user_category_update_trigger
 after update on user_categories
   for each row execute procedure user_category_update_values();

   