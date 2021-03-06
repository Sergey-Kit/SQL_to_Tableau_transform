WITH First_touch AS (
	SELECT DISTINCT localUserId
		,CAST(LEFT(dateTime, 10) AS DATE) AS Date
		,os
		,utm_source
		,utm_medium
		,event
	FROM Wazzup.dbo.Worksheet$
	WHERE (event = 'landing.unique-visit')
	),
	Second_part AS (
		SELECT DISTINCT localUserId
			,event
			--,COUNT(localUserId)
		FROM Wazzup.dbo.Worksheet$
		WHERE (event = 'register-confirm-code-success')
		--ORDER BY localUserId
	),
	Third_part AS (
		SELECT DISTINCT localUserId
			,event
			--,COUNT(localUserId)
		FROM Wazzup.dbo.Worksheet$
		WHERE (event = 'editor.add.click')
		--ORDER BY localUserId
	),
	Step_1 AS (
		SELECT T1.localUserId
				,T1.Date
				,T1.First_OS
				,T1.First_utm_source
				,T1.First_utm_medium
				,T1.event AS Layer1
				,Second_part.event AS Layer2
				--,Second_part.event + T1.event
		FROM
			(SELECT 
				t_1.localUserId
				,t_1.Date
				,t_2.First_OS
				,t_1.First_utm_source
				,t_1.First_utm_medium
				,t_1.event

			FROM
				(SELECT DISTINCT First_touch.localUserId
					,FIRST_VALUE(Date) OVER (PARTITION BY First_touch.localUserId ORDER BY First_touch.localUserId) AS Date
					,FIRST_VALUE(utm_source) OVER (PARTITION BY First_touch.localUserId ORDER BY First_touch.localUserId) AS First_utm_source
					,FIRST_VALUE(utm_medium) OVER (PARTITION BY First_touch.localUserId ORDER BY First_touch.localUserId) AS First_utm_medium
					,event
				FROM First_touch
				--WHERE os IS NULL 
				--WHERE ((event = 'landing.unique-visit') AND (localUserId = '26655377-0fa5-40dd-aa97-4df011355ee9'))
				--ORDER BY Date--localUserId  --  --
				) AS t_1
				LEFT JOIN
					(SELECT DISTINCT
						First_touch.localUserId
						,First_OS
					FROM 
						First_touch
					INNER JOIN
						(SELECT DISTINCT
							First_touch.localUserId,
							First_touch.Date,
							FIRST_VALUE(First_touch.os) OVER (PARTITION BY localUserId ORDER BY Date) as First_OS
						FROM First_touch
						WHERE os IS NOT NULL
						) AS Non_Null_First_OS
					ON First_touch.localUserId = Non_Null_First_OS.localUserId) AS t_2
				ON t_1.localUserId = t_2.localUserId) AS T1
			LEFT JOIN Second_part --AS Second_part
			ON T1.localUserId = Second_part.localUserId
	)

SELECT Step_1.localUserId
	,Step_1.Date
	,Step_1.First_OS
	,Step_1.First_utm_source
	,Step_1.First_utm_medium
	,Step_1.Layer1
	,Step_1.Layer2
	,T2.Trird_event AS Layer3
FROM
    Step_1
LEFT JOIN (
	SELECT L3.localUserId
		,Third_part.event AS Trird_event
	FROM(
		(SELECT Step_1.localUserId
		FROM Step_1 --, Third_part
		WHERE Step_1.Layer2 IS NOT NULL) AS L3
	LEFT JOIN Third_part
	ON L3.localUserId = Third_part.localUserId)) AS T2
ON Step_1.localUserId = T2.localUserId --AS T23