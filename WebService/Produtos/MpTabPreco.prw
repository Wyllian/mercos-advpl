#include 'protheus.ch'

/*/{Protheus.doc} MpTabPreco
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpTabPreco
	DATA cEntid
	DATA cAppToken
	DATA cEmpToken
	DATA cId
	DATA cUrlBase

	method new() constructor
	method GetTabPrc(cId)							// Obtem Produto
	method PostTabPrc()								// Incluir Produto
	method PutTabPrc(cId)							// Altera Produto

endclass

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} new
Metodo construtor
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new() class MpTabPreco
	::cEntid	:= 'tabelas_preco'
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetProd
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method GetTabPrc(cId) class MpTabPreco
	Local oJson
	Local oRet	:= {}

	Default cId	:= ''

	oRestTbPrc := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestTbPrc:setPath("")

	If oRestTbPrc:Get(aHeader)
		U_DH05A00L("tabelas_preco","GET",oRestTbPrc:cHost,oRestTbPrc:cResult)

		If FWJsonDeserialize(oRestTbPrc:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf

	cStatus	:= oRestTbPrc:oResponseH:cStatusCode

return { oRet, cStatus}

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PosProd
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PostTabPrc() class MpTabPreco
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aTabPrc	:= {}
	Local cStatus	:= ""

	oRestTbPrc := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadTbPrc() )

	oRestTbPrc:setPath("")
	oRestTbPrc:SetPostParams(cJson)

	If oRestTbPrc:Post(aHeader)
		U_DH05A00L("tabelas_preco","POST",oRestTbPrc:cHost,cJson)

		nPosID	:= ASCAN(oRestTbPrc:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestTbPrc:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestTbPrc:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestTbPrc:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus	:= oRestTbPrc:oResponseH:cStatusCode
	aTabPrc := { Val(cNewId), cNewUrl, cStatus }

return aTabPrc

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutProd
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PutTabPrc(cId) class MpTabPreco
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local aTabPrc	:= {}
	Local _y		:= 0

	oRestTbPrc := FWRest():New(::cUrlBase + '/' + AllTrim(cValToChar(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadTbPrc() )

	oRestTbPrc:setPath("")
	oRestTbPrc:SetPostParams(cJson)

	If oRestTbPrc:Put(aHeader, cJson)
		U_DH05A00L("tabelas_preco","PUT",oRestTbPrc:cHost,cJson)

		nPosID	:= ASCAN(oRestTbPrc:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestTbPrc:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestTbPrc:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestTbPrc:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus	:= oRestTbPrc:oResponseH:cStatusCode
	aTabPrc := { Val(cNewId), cNewUrl, cStatus }

return aTabPrc

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadTbPrc
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined

@type function
/*/
Static Function LoadTbPrc()
	Local aRet := {}

	cNome		:= DA0->DA0_DESCRI
	cTipo		:= 'P' // P = Preço Livre, A = Acréscimo, D = Desconto
	cAcresc		:= ''
	cDescon		:= ''
	cDel		:= 'false'

	AADD(aRet,{ "nome"				, cNome										, "String"	, 100})
	AADD(aRet,{ "tipo"				, cTipo										, "String"	, 1})
	AADD(aRet,{ "acrescimo"			, IIF(!Empty(cAcresc), cAcresc, 'null')		, "Double"	, 0})
	AADD(aRet,{ "desconto"			, IIF(!Empty(cDescon), cDescon, 'null')		, "Double"	, 0})
	AADD(aRet,{ "excluido"			, cDel										, "Boolean"	, 0})

Return aRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} MontaJson
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined
@param aDados, array, descricao
@type function
/*/
Static Function MontaJson( aDados )
	Local cJson	:= ""
	Local x		:= 0

	cJson := '{'

	For x := 1 to Len(aDados)
		cJson += '"' + aDados[x][1] + '": '

		if aDados[x][3] == 'String'
			if len(aDados[x][2]) > aDados[x][4] .And. aDados[x][4] <> 0
				cJson += '"' + SubStr(aDados[x][2], 1, aDados[x][4]) + '"'
			else
				cJson += '"' + aDados[x][2] + '"'
			endif

		elseif aDados[x][3] == 'Array'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Boolean'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Double'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Integer'
			cJson += aDados[x][2]

		endif

		if x < Len(aDados)
			cJson += ', '
		endif

	Next x

	cJson += '}'

Return cJson
