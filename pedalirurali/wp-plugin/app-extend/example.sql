SELECT SQL_CALC_FOUND_ROWS  pr_posts.ID FROM pr_posts  
       LEFT JOIN pr_term_relationships ON (pr_posts.ID = pr_term_relationships.object_id) 
       WHERE 1=1  AND (  (  pr_term_relationships.term_taxonomy_id IN (25)     AND     0 = 1  )) 
       AND pr_posts.post_type = 'mec-events' AND ((pr_posts.post_status = 'publish')) 
       GROUP BY pr_posts.ID ORDER BY pr_posts.post_date DESC LIMIT 0, 10


       SELECT SQL_CALC_FOUND_ROWS  pr_posts.ID FROM pr_posts  
            LEFT JOIN pr_term_relationships ON (pr_posts.ID = pr_term_relationships.object_id)  
            LEFT JOIN pr_term_relationships AS tt1 ON (pr_posts.ID = tt1.object_id) 
            WHERE 1=1  
                AND (pr_term_relationships.term_taxonomy_id IN (20)   AND   tt1.term_taxonomy_id IN (38)) 
                AND pr_posts.post_type = 'mec-events' AND ((pr_posts.post_status = 'publish'))
        GROUP BY pr_posts.ID 
        ORDER BY pr_posts.post_date DESC 
        LIMIT 0, 10

        
       SELECT SQL_CALC_FOUND_ROWS  pr_posts.ID FROM pr_posts  
            LEFT JOIN pr_term_relationships ON (pr_posts.ID = pr_term_relationships.object_id)  
            LEFT JOIN pr_term_relationships AS tt1 ON (pr_posts.ID = tt1.object_id) 
            WHERE   
                (pr_term_relationships.term_taxonomy_id = 30 AND  tt1.term_taxonomy_id = 24) 
                AND pr_posts.post_type = 'mec-events' 
                AND pr_posts.post_status = 'publish'
        GROUP BY pr_posts.ID 
        ORDER BY pr_posts.post_date DESC 
        LIMIT 0, 10

select P.ID, P.post_title from pr_posts as P inner join (
       SELECT  pr_posts.ID as ID FROM pr_posts  
            LEFT JOIN pr_term_relationships        ON (pr_posts.ID = pr_term_relationships.object_id)  
            LEFT JOIN pr_term_relationships AS tt1 ON (pr_posts.ID = tt1.object_id) 
            WHERE   

                (pr_term_relationships.term_taxonomy_id = 30 AND  tt1.term_taxonomy_id = 24) 

                AND pr_posts.post_type = 'mec-events' 
                AND pr_posts.post_status = 'publish'

        GROUP BY pr_posts.ID 
) P2 on P2.ID = P.ID
ORDER BY P.post_date DESC 
LIMIT 0, 10

---- order by data inizio evento

select P.ID, P.post_title from pr_posts as P inner join (
       SELECT  pr_posts.ID as ID FROM pr_posts  
            LEFT JOIN pr_term_relationships AS tt0 ON (pr_posts.ID = tt0.object_id)  
            LEFT JOIN pr_term_relationships AS tt1 ON (pr_posts.ID = tt1.object_id)
            WHERE   

                (tt0.term_taxonomy_id = 30 AND  tt1.term_taxonomy_id = 24) 
                
                AND pr_posts.post_type = 'mec-events' 
                AND pr_posts.post_status = 'publish'
                
        GROUP BY pr_posts.ID 
) P2 on P2.ID = P.ID
ORDER BY P.post_date DESC 
LIMIT 0, 10

INNER JOIN (
       SELECT PP.ID as ID FROM pr_posts PP
            LEFT JOIN pr_term_relationships AS tt0 ON (PP.ID = tt0.object_id)  
            LEFT JOIN pr_term_relationships AS tt1 ON (PP.ID = tt1.object_id)
            WHERE   
                (tt0.term_taxonomy_id = 30 AND  tt1.term_taxonomy_id = 24) 
                AND PP.post_type = 'mec-events' 
                AND PP.post_status = 'publish'
        GROUP BY PP.ID 
) P2 on P2.ID = P.ID



select P.ID, P.post_title from pr_posts as P 
inner join (
       SELECT  pr_posts.ID as ID FROM pr_posts  
            LEFT JOIN pr_term_relationships AS tt0 ON (pr_posts.ID = tt0.object_id)  
            LEFT JOIN pr_term_relationships AS tt1 ON (pr_posts.ID = tt1.object_id)
            WHERE   
                (tt0.term_taxonomy_id = 50) 
                AND pr_posts.post_type = 'mec-events' 
                AND pr_posts.post_status = 'publish'
        GROUP BY pr_posts.ID 
) P2 on P2.ID = P.ID
, pr_mec_dates D 
where P.id = D.post_id
ORDER BY D.tstart 
LIMIT 0, 10




select P.ID, P.post_title, ( SELECT count(F.*) as TOT from pr_favorite_events F WHERE F.post_id = P.ID ) as favorites from pr_posts as P inner join (
       SELECT  pr_posts.ID as ID FROM pr_posts  
            LEFT JOIN pr_term_relationships AS tt0 ON (pr_posts.ID = tt0.object_id)  
            LEFT JOIN pr_term_relationships AS tt1 ON (pr_posts.ID = tt1.object_id)
            WHERE   

                --(tt0.term_taxonomy_id = 30 AND  tt1.term_taxonomy_id = 24) 
                
                AND pr_posts.post_type = 'mec-events' 
                AND pr_posts.post_status = 'publish'
                
        GROUP BY pr_posts.ID 
) P2 on P2.ID = P.ID

ORDER BY P.post_date DESC 
LIMIT 0, 10


SELECT P.id, P.post_title as title, P.post_content as content , '0' as favorites  
FROM pr_posts P  WHERE P.post_type = 'mec-events' AND P.post_status = 'publish'  AND P.id in ( 2726,2825 ) LIMIT 0, 10



SELECT P.id, P.post_title as title, P.post_content as content , '0' as favorites  
FROM pr_posts P  
INNER JOIN pr_mec_dates D on (P.id = D.post_id)  
INNER JOIN ( 
         SELECT PP.ID as ID FROM pr_posts PP  LEFT JOIN pr_term_relationships AS tt_evt ON (PP.ID = tt_evt.object_id) 
         WHERE  ( tt_evt.term_taxonomy_id = 49)  AND PP.post_type = 'mec-events'  AND PP.post_status = 'publish' GROUP BY PP.ID 
 ) P2 on P2.ID = P.ID 
WHERE P.post_type = 'mec-events' AND P.post_status = 'publish'  ORDER BY D.tstart  LIMIT 0, 10