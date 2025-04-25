DROP VIEW cohort_analysis;

CREATE OR REPLACE VIEW public.cohort_analysis AS 
WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS num_orders,
            c.age,
            c.countryfull,
            c.givenname,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY c.customerkey, s.customerkey, s.orderdate, c.age, c.countryfull, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
    num_orders,
    age,
    countryfull,
    CONCAT(TRIM(givenname), ' ', TRIM(surname)) AS cleaned_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;