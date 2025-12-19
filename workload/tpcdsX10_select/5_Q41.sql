-- start query 41 in stream 0 using template query41.tpl
select  distinct(i_product_name)
 from item i1
 where i_manufact_id between 980 and 980+40 
   and (select count(*) as item_cnt
        from item
        where (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'spring' or i_color = 'metallic') and 
        (i_units = 'Dram' or i_units = 'Gram') and
        (i_size = 'small' or i_size = 'extra large')
        ) or
        (i_category = 'Women' and
        (i_color = 'burnished' or i_color = 'medium') and
        (i_units = 'Bunch' or i_units = 'Box') and
        (i_size = 'petite' or i_size = 'N/A')
        ) or
        (i_category = 'Men' and
        (i_color = 'goldenrod' or i_color = 'cornsilk') and
        (i_units = 'Gross' or i_units = 'Pound') and
        (i_size = 'economy' or i_size = 'medium')
        ) or
        (i_category = 'Men' and
        (i_color = 'puff' or i_color = 'turquoise') and
        (i_units = 'Ton' or i_units = 'Pallet') and
        (i_size = 'small' or i_size = 'extra large')
        ))) or
       (i_manufact = i1.i_manufact and
        ((i_category = 'Women' and 
        (i_color = 'grey' or i_color = 'peru') and 
        (i_units = 'Ounce' or i_units = 'Each') and
        (i_size = 'small' or i_size = 'extra large')
        ) or
        (i_category = 'Women' and
        (i_color = 'sky' or i_color = 'aquamarine') and
        (i_units = 'Unknown' or i_units = 'Bundle') and
        (i_size = 'petite' or i_size = 'N/A')
        ) or
        (i_category = 'Men' and
        (i_color = 'forest' or i_color = 'ghost') and
        (i_units = 'Carton' or i_units = 'Tbl') and
        (i_size = 'economy' or i_size = 'medium')
        ) or
        (i_category = 'Men' and
        (i_color = 'smoke' or i_color = 'ivory') and
        (i_units = 'Cup' or i_units = 'Case') and
        (i_size = 'small' or i_size = 'extra large')
        )))) > 0
 order by i_product_name
 LIMIT 100;

-- end query 41 in stream 0 using template query41.tpl
