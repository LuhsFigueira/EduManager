---- 1. Identificar alunos com matrícula vencida nos últimos 30 dias.
SELECT * 
FROM ALUNOS ALU
JOIN MATRICULAS MAT 
ON ALU.ID = MAT.id_aluno
WHERE MAT.status not in ('encerrada')
AND MAT.data_fim BETWEEN DATE('now', '-30 days') AND DATE('now');


---2. Listar os alunos que optaram por renovação automática.

SELECT DISTINCT
 ALU.ID
,ALU.NOME
,ALU.EMAIL
,CASE
  WHEN ALU.ATIVO = 1 THEN 'ATIVO'
  WHEN ALU.ATIVO = 0 THEN 'INATIVO'
  ELSE ALU.ATIVO end AS 'Situacao_Aluno'
,CASE
  WHEN MAT.renovacao_automatica = 1 THEN 'ATIVA'
  WHEN MAT.renovacao_automatica = 0 THEN 'INATIVA'
  ELSE MAT.renovacao_automatica end AS 'Renovacao_Automatica'
FROM ALUNOS ALU
JOIN MATRICULAS MAT 
ON ALU.ID = MAT.id_aluno
WHERE MAT.renovacao_automatica = 1


--- 3. Verificar cursos que têm inadimplência acima de 20%.

SELECT
   CRS.ID
  ,CRS.nome AS curso
  ,COUNT(MAT.id) AS total_matriculas
  ,SUM(CASE WHEN PAG.status = 'recusado' THEN 1 ELSE 0 END) AS inadimplentes
  ,ROUND(100.0 * SUM(CASE WHEN PAG.status = 'recusado' THEN 1 ELSE 0 END) / COUNT(MAT.id), 2) AS percentual_inadimplencia
FROM MATRICULAS MAT
JOIN CURSOS CRS ON MAT.id_curso = CRS.id
JOIN PAGAMENTOS PAG 
  ON PAG.id = (
    SELECT MAX(P2.id)
    FROM PAGAMENTOS P2
    WHERE P2.id_matricula = MAT.id
  )
WHERE MAT.status = 'ativa'
GROUP BY CRS.nome
HAVING percentual_inadimplencia > 20;
