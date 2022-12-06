SELECT * FROM `dsd-fall22.dsdbq.generated_table` LIMIT 1000

select distinct category_code from `dsd-fall22.dsdbq.generated_table`

select distinct event_type from `dsd-fall22.dsdbq.generated_table` --view, purchase, cart

select distinct brand from `dsd-fall22.dsdbq.generated_table`

-- number of views per brand on in a time period

select brand, count(1) as number_of_views from (select * from `dsd-fall22.dsdbq.generated_table` where event_type = 'view' and brand <> '' ) group by brand order by number_of_views DESC

-- average price of a brand

select brand, avg(price) as avg_price from (select * from `dsd-fall22.dsdbq.generated_table` where event_type = 'view' and brand <> '' ) group by brand order by avg_price DESC


-- amount per day purchase

select event_time, sum(price) as total_price from `dsd-fall22.dsdbq.generated_table` group by event_time

select count(distinct product_id) from `dsd-fall22.dsdbq.generated_table`


-- count per day purchase

select date(event_time) as event_date, count(1) as total_count from `dsd-fall22.dsdbq.generated_table` group by date(event_time)



-- sales by brand

select brand, count(1) as number_of_sales from (select * from `dsd-fall22.dsdbq.generated_table` where event_type = 'purchase' and brand <> '') as a group by brand order by number_of_sales desc;

--select brand, count(1) as number_of_sales from `dsd-fall22.dsdbq.generated_table` as a group by brand having event_type = 'purchase';

