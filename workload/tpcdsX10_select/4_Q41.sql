-- start query 41 in stream 0 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 885 and 885+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'chartreuse' or i_color = 'dark') and 
        (i_units = 'Lb' or i_units = 'Case') and
        (i_size = 'extra large' or i_size = 'large')
        ) or
        (i_category = 'Women' and
        (i_color = 'azure' or i_color = 'seashell') and
        (i_units = 'Cup' or i_units = 'Ton') and
        (i_size = 'medium' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'yellow' or i_color = 'midnight') and
        (i_units = 'Oz' or i_units = 'Pallet') and
        (i_size = 'petite' or i_size = 'small')
        ) or
        (i_category = 'Men' and
        (i_color = 'blush' or i_color = 'blue') and
        (i_units = 'Bundle' or i_units = 'Gram') and
        (i_size = 'extra large' or i_size = 'large')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'sky' or i_color = 'burlywood') and 
        (i_units = 'Unknown' or i_units = 'Tbl') and
        (i_size = 'extra large' or i_size = 'large')
        ) or
        (i_category = 'Women' and
        (i_color = 'dim' or i_color = 'peach') and
        (i_units = 'Gross' or i_units = 'Tsp') and
        (i_size = 'medium' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'ghost' or i_color = 'dodger') and
        (i_units = 'Pound' or i_units = 'Dozen') and
        (i_size = 'petite' or i_size = 'small')
        ) or
        (i_category = 'Men' and
        (i_color = 'cream' or i_color = 'puff') and
        (i_units = 'N/A' or i_units = 'Bunch') and
        (i_size = 'extra large' or i_size = 'large')
        )))) > 0
 order by i_product_name
 LIMIT 100;

-- end query 41 in stream 0 using template query41.tpl
