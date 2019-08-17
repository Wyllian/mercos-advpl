#include 'protheus.ch'

/*/{Protheus.doc} MpProdutos
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpProdutos
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId
	DATA cUltDt

	method New() constructor
	method GetProd( cId, cUltDt)				// Obtem Produto
	method PostProd()							// Incluir Produto
	method PutProd(cId)							// Altera Produto

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
method new() class MpProdutos
	::cEntid	:= "produtos"
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
method GetProd(cId, cUltDt) class MpProdutos
	Local oJson
	Local oRet			:= {}
	Local cResultAux	:= ''
	Local aResult		:= {}
	Local x				:= 0
	Local cCompUrl		:= ''

	Default cId			:= ''
	Default cUltDt		:= ''

	If !Empty(cId)
		cCompUrl	:= '/' + AllTrim(cId)
	EndIf
	If !Empty(cUltDt)
		cUltDt		:= StrTran( cUltDt, ' ','%20')
		cCompUrl	:= '?alterado_apos=' + AllTrim(cUltDt)
	EndIf

	oRestProd	:= FWRest():New(::cUrlBase + cCompUrl)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestProd:setPath("")

	If oRestProd:Get(aHeader)
		U_DH05A00L(::cEntid,"GET",oRestProd:cHost,oRestProd:cResult)

		/* Devido a limitação do FWJsonDeserialize */
		cResultAux	:= StrTran(oRestProd:cResult,'},{','}]|[{')
		aResult		:= StrTokArr(cResultAux,'|')

		For x := 1 To Len( aResult )
			If FWJsonDeserialize(aResult[x], @oJson)
				AADD( oRet, oJson)
			EndIf

			freeobj( oJson )
		Next x

	EndIf

	cStatus	:= oRestProd:oResponseH:cStatusCode

return { oRet, cStatus }

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostProd
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined
@type function
/*/
method PostProd() class MpProdutos
	Local cJson		:= ""
	Local cNewId	:= '0'
	Local cNewUrl	:= ""
	Local aProd		:= {}

	oRestProd := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadProd() )

	oRestProd:setPath("")
	oRestProd:SetPostParams(cJson)

	If oRestProd:Post(aHeader)
		U_DH05A00L(::cEntid,"POST",oRestProd:cHost,cJson)

		nPosID	:= ASCAN(oRestProd:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestProd:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestProd:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestProd:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	Else
		U_DH05A00L(::cEntid,"POST",oRestProd:cHost,cJson)
	EndIf

	cStatus	:= oRestProd:oResponseH:cStatusCode
	aProd	:= { Val(cNewId), cNewUrl, cStatus }

return aProd

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutProd
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined
@type function
/*/
method PutProd( cId ) class MpProdutos
	Local cJson		:= ""
	Local cNewId	:= "0"
	Local cNewUrl	:= ""
	Local aProd		:= {}

	oRestProd := FWRest():New( ::cUrlBase + '/' + AllTrim( cValToChar( cId ) ) )

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadProd() )

	oRestProd:setPath("")
	oRestProd:SetPostParams(cJson)

	If oRestProd:Put(aHeader, cJson)
		U_DH05A00L(::cEntid,"PUT",oRestProd:cHost,cJson)

		nPosID	:= ASCAN( oRestProd:oResponseH:aHeaderFields, {|x| AllTrim(x[1]) == "MeusPedidosID"})
		nPosURL	:= ASCAN( oRestProd:oResponseH:aHeaderFields, {|x| AllTrim(x[1]) == "MeusPedidosURL"})

		If nPosId > 0
			cNewId := AllTrim( oRestProd:oResponseH:aHeaderFields[ nPosID ][2] )
		EndIf

		If nPosURL > 0
			cNewUrl := AllTrim( oRestProd:oResponseH:aHeaderFields[ nPosURL ][2] )
		EndIf
	Else
		U_DH05A00L(::cEntid,"PUT",oRestProd:cHost,cJson)
	EndIf

	cStatus	:= oRestProd:oResponseH:cStatusCode
	aProd	:= { Val(cNewId), cNewUrl, cStatus}

return aProd

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadProd
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined
@type function
/*/
Static Function LoadProd()
	Local aRet := {}

	cCod		:= AllTrim(SB1->B1_COD)
	cNome		:= AllTrim(SB1->B1_DESC)
	cUnid		:= AllTrim(SB1->B1_UM)
	cNcm		:= AllTrim(SB1->B1_POSIPI)
	cDel		:= 'false'
	cAtivo		:= IIF( SB1->B1_MSBLQL <> '1', 'true', 'false' )
	cPrcTab		:= '0.00'									// A definir
	cPrcMin		:= '0.00'									// A definir
	cComis		:= ''										// A definir
	cSt			:= ''										// A definir
	cIpi		:= cValToChar(SB1->B1_IPI)
	cTpIpi		:= 'P'										// P = Percentual, V = Valor
	cMoeda		:= '0'										// 0 = Real, 1 = Real, 2 = Euro
	cSaldoEst	:= '0.00'									// Por enquanto não irá controlar estoque
	cObs		:= ''
	cGradeCor	:= ''
	cGradeTam	:= ''
	cIdCateg	:= Str(Posicione("SBM", 1, xFilial("SBM") + SB1->B1_GRUPO, "BM_IDMP"))
	cMulti		:= '0.00'									// A definir

	AADD(aRet,{ "nome"				, cNome										, "String"	, 100})
	AADD(aRet,{ "preco_tabela"		, cPrcTab									, "Double"	, 0})
	AADD(aRet,{ "preco_minimo"		, cPrcMin									, "Double"	, 0})
	AADD(aRet,{ "codigo"			, cCod										, "String"	, 50})
	AADD(aRet,{ "comissao"			, IIF(!Empty(cComis), cComis, 'null')		, "Double"	, 0})
	AADD(aRet,{ "ipi"				, IIF(!Empty(cIpi), cIpi, 'null')			, "Double"	, 0})
	AADD(aRet,{ "tipo_ipi"			, cTpIpi									, "String"	, 1})
	AADD(aRet,{ "st"				, IIF(!Empty(cSt), cSt, 'null')				, "Double"	, 0})
	AADD(aRet,{ "moeda"				, cMoeda									, "Double"	, 0})
	AADD(aRet,{ "unidade"			, cUnid										, "String"	, 10})
	AADD(aRet,{ "saldo_estoque"		, cSaldoEst									, "Double"	, 0})
	AADD(aRet,{ "observacoes"		, cObs										, "String"	, 500})
	AADD(aRet,{ "grade_cores"		, IIF(!Empty(cGradeCor), cGradeCor, 'null')	, "Array"	, 0})
	AADD(aRet,{ "grade_tamanhos"	, IIF(!Empty(cGradeTam), cGradeTam, 'null')	, "Array"	, 0})
	AADD(aRet,{ "excluido"			, cDel										, "Boolean"	, 0})
	AADD(aRet,{ "ativo"				, cAtivo									, "Boolean"	, 0})
	AADD(aRet,{ "categoria_id"		, IIF(Val(cIdCateg) > 0, cIdCateg, 'null')	, "Integer"	, 0})
	AADD(aRet,{ "codigo_ncm"		, cNcm										, "String"	, 0})
	AADD(aRet,{ "multiplo"			, IIF(Val(cMulti) > 0, cMulti, 'null'	)	, "Double"	, 0})

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
