USE Master;
GO
SELECT cp.*,qp.query_plan FROM sys.dm_exec_cached_plans as cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) as qp
WHERE objtype='Proc'
ORDER  BY size_in_bytes DESC
GO

USE Adventureworks;
GO

SELECT 
	sp.name
,	X.query_plan
FROM sys.procedures as sp
INNER JOIN sys.dm_exec_procedure_stats as ps
ON sp.object_id=ps.object_id --
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) as X
GO
