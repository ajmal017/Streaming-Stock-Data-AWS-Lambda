SELECT name, ts, hour, high
FROM
(SELECT name, ts, SUBSTRING(ts, 12, 2) AS hour, high, RANK () OVER ( 
			PARTITION BY name, SUBSTRING(ts, 12, 2)
			ORDER BY high DESC, ts DESC
		) price_rank 
FROM "20") t1
WHERE t1.price_rank = 1
ORDER BY 1, 3

