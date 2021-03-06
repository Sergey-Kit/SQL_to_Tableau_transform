

WITH Fourth_part AS (
	SELECT DISTINCT localUserId
		,event
	FROM Wazzup.dbo.Worksheet$
	WHERE (event = 'editor-link.copy.click')
	),
	Fifth_part AS (
		SELECT DISTINCT localUserId
			,event
		FROM Wazzup.dbo.Worksheet$
		WHERE (event = 'payment.attempt')
	),
	Sixth_part AS (
		SELECT DISTINCT localUserId
			,event
		FROM Wazzup.dbo.Worksheet$
		WHERE (event = 'payment.success')
	),

	Step_3 AS (
		SELECT Wazzup_Layer2$.localUserId
			,Wazzup_Layer2$.Date
			,Wazzup_Layer2$.First_OS
			,Wazzup_Layer2$.First_utm_source
			,Wazzup_Layer2$.First_utm_medium
			,Wazzup_Layer2$.Layer1
			,Wazzup_Layer2$.Layer2
			,Wazzup_Layer2$.Layer3
			,T3.Fourth_event AS Layer4
		FROM
			Wazzup.dbo.Wazzup_Layer2$
		LEFT JOIN (
			SELECT L4.localUserId
				,Fourth_part.event AS Fourth_event
			FROM(
				(SELECT Wazzup_Layer2$.localUserId
				FROM Wazzup.dbo.Wazzup_Layer2$ --, Third_part
				WHERE Wazzup_Layer2$.Layer3 != 'NULL') AS L4
			LEFT JOIN Fourth_part
			ON L4.localUserId = Fourth_part.localUserId)) AS T3
		ON Wazzup_Layer2$.localUserId = T3.localUserId --AS T23
	),
	Step_4 AS (
		SELECT Step_3.localUserId
			,Step_3.Date
			,Step_3.First_OS
			,Step_3.First_utm_source
			,Step_3.First_utm_medium
			,Step_3.Layer1
			,Step_3.Layer2
			,Step_3.Layer3
			,Step_3.Layer4
			,T4.Fifth_event AS Layer5
		FROM
			Step_3
		LEFT JOIN (
			SELECT L5.localUserId
				,Fifth_part.event AS Fifth_event
			FROM(
				(SELECT Step_3.localUserId
				FROM Step_3 --, Third_part
				WHERE Step_3.Layer4 IS NOT NULL) AS L5
			LEFT JOIN Fifth_part
			ON L5.localUserId = Fifth_part.localUserId)) AS T4
		ON Step_3.localUserId = T4.localUserId --AS T23
	)

SELECT Step_4.localUserId
			--,CAST(LEFT(Wazzup_Layer2$.Date, 10) AS DATE) AS Date
			,Step_4.Date
			,Step_4.First_OS
			,Step_4.First_utm_source
			,Step_4.First_utm_medium
			,Step_4.Layer1
			,Step_4.Layer2
			,Step_4.Layer3
			,Step_4.Layer4
			,Step_4.Layer5
			,T5.Sixth_event AS Layer6
FROM
	Step_4
LEFT JOIN (
	SELECT L6.localUserId
		,Sixth_part.event AS Sixth_event
	FROM(
		(SELECT Step_4.localUserId
		FROM Step_4 --, Third_part
		WHERE Step_4.Layer5 IS NOT NULL) AS L6
	LEFT JOIN Sixth_part
	ON L6.localUserId = Sixth_part.localUserId)) AS T5
ON Step_4.localUserId = T5.localUserId --AS T23

--WHERE Layer6 IS NOT NULL