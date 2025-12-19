-- start query 41 in stream 0 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 790 and 790+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'cream' or i_color = 'sienna') and 
        (i_units = 'Gross' or i_units = 'Ounce') and
        (i_size = 'petite' or i_size = 'large')
        ) or
        (i_category = 'Women' and
        (i_color = 'firebrick' or i_color = 'lace') and
        (i_units = 'Bundle' or i_units = 'Each') and
        (i_size = 'N/A' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'orange' or i_color = 'purple') and
        (i_units = 'Dram' or i_units = 'Case') and
        (i_size = 'small' or i_size = 'medium')
        ) or
        (i_category = 'Men' and
        (i_color = 'indian' or i_color = 'light') and
        (i_units = 'Lb' or i_units = 'Unknown') and
        (i_size = 'petite' or i_size = 'large')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'cornsilk' or i_color = 'blanched') and 
        (i_units = 'Carton' or i_units = 'Gram') and
        (i_size = 'petite' or i_size = 'large')
        ) or
        (i_category = 'Women' and
        (i_color = 'khaki' or i_color = 'chiffon') and
        (i_units = 'N/A' or i_units = 'Ton') and
        (i_size = 'N/A' or i_size = 'economy')
        ) or
        (i_category = 'Men' and
        (i_color = 'chartreuse' or i_color = 'brown') and
        (i_units = 'Tbl' or i_units = 'Tsp') and
        (i_size = 'small' or i_size = 'medium')
        ) or
        (i_category = 'Men' and
        (i_color = 'lavender' or i_color = 'hot') and
        (i_units = 'Oz' or i_units = 'Dozen') and
        (i_size = 'petite' or i_size = 'large')
        )))) > 0
 order by i_product_name
 LIMIT 100;

-- end query 41 in stream 0 using template query41.tpl
