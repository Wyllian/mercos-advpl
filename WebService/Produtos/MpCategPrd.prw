#include 'protheus.ch'

/*/{Protheus.doc} MpCategPrd
//TODO Descrição auto-gerada.
@author Wyllian Marquardt
@since 15/09/2017
@version undefined

@type class
/*/
class MpCategPrd
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method new() constructor
	method GetCateg(cId)							// Obtem Produto
	method PostCateg()								// Incluir Produto
	method PutCateg(cId)							// Altera Produto

endclass

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} new
Metodo construtor
@author Wyllian Marquardt
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new() class MpCategPrd
	::cEntid	:= 'categorias'
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetProd
//TODO Descrição auto-gerada.
@author Wyllian Marquardt
@since 17/07/2017
@version undefined

@type function
/*/
method GetCateg(cId) class MpCategPrd
	Local oJson
	Local oRet	:= {}

	Default cId	:= ''

	oRestCateg := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestCateg:setPath("")

	If oRestCateg:Get(aHeader)
		U_DH05A00L("categorias","GET",oRestCateg:cHost,oRestCateg:cResult)

		If FWJsonDeserialize(oRestCateg:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf

	cStatus	:= ORESTCATEG:ORESPONSEH:CSTATUSCODE

return { oRet, cStatus}

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PosProd
//TODO Descrição auto-gerada.
@author Wyllian Marquardt
@since 17/07/2017
@version undefined

@type function
/*/
method PostCateg() class MpCategPrd
	Local cJson		:= ""
	Local cNewId	:= '0'
	Local cNewUrl	:= ""
	Local aCateg	:= {}

	oRestCateg := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadCateg() )

	oRestCateg:setPath("")
	oRestCateg:SetPostParams(cJson)

	If oRestCateg:Post(aHeader)
		U_DH05A00L("categorias","POST",oRestCateg:cHost,cJson)

		nPosID	:= ASCAN(oRestCateg:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestCateg:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestCateg:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestCateg:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	Else
		U_DH05A00L("categorias","POST",oRestCateg:cHost,cJson)
	EndIf

	cStatus	:= oRestCateg:oResponseH:cStatusCode
	aCateg := { Val(cNewId), cNewUrl, cStatus }

return aCateg

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutProd
//TODO Descrição auto-gerada.
@author Wyllian Marquardt
@since 17/07/2017
@version undefined

@type function
/*/
method PutCateg(cId) class MpCategPrd
	Local cJson		:= ""
	Local cNewId	:= '0'
	Local cNewUrl	:= ""
	Local aCateg	:= {}

	oRestCateg := FWRest():New(::cUrlBase + '/' + AllTrim(cValToChar(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadCateg() )

	oRestCateg:setPath("")
	oRestCateg:SetPostParams(cJson)

	If oRestCateg:Put(aHeader, cJson)
		U_DH05A00L("categorias","PUT",oRestCateg:cHost,cJson)

		nPosID	:= ASCAN(oRestCateg:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestCateg:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestCateg:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestCateg:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	Else
		U_DH05A00L("categorias","PUT",oRestCateg:cHost,cJson)
	EndIf

	cStatus	:= oRestCateg:oResponseH:cStatusCode
	aCateg	:= { Val(cNewId), cNewUrl, cStatus }

return aCateg

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadCateg
//TODO Descrição auto-gerada.
@author Wyllian Marquardt
@since 24/08/2017
@version undefined

@type function
/*/
Static Function LoadCateg()
	Local aRet := {}

	cNome		:= AllTrim(SBM->BM_DESC)
	cDel		:= 'false'

	AADD(aRet,{ "nome"		, cNome						, "String"	, 100})
	AADD(aRet,{ "excluido"	, cDel						, "Boolean"	, 0})

Return aRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} MontaJson
//TODO Descrição auto-gerada.
@author Wyllian Marquardt
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
