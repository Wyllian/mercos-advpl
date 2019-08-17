#include 'protheus.ch'

/*/{Protheus.doc} MpPedidos
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpPedidos
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId
	DATA cUltDt
	DATA aPedEdi

	method New()										// Constructor
	method GetPed(cId, cUltDt)							// Obtem Pedido
	method CancelPed()									// Cancelar Pedido
	method PostPed()									// Inclui Pedido
	method PutPed(cId)									// Altera Pedido
	method PostPedEdi(aPedEdi)							// Inclui Pedido Edi

endclass

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} New
Metodo construtor
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method New() class MpPedidos
	::cEntid	:= "pedidos"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetPed
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined
@type function
/*/
method GetPed( cId, cUltDt) class MpPedidos
	Local oJson
	Local oRet		:= {}
	Local cCompUrl	:= ''

	Default cId		:= ''
	Default cUltDt	:= ''

	If !Empty(cId)
		cCompUrl	:= '/' + AllTrim(cId)
	EndIf
	If !Empty(cUltDt)
		cUltDt		:= StrTran( cUltDt, ' ','%20')
		cCompUrl	:= '?alterado_apos=' + AllTrim(cUltDt)
	EndIf

	oRestPed	:= FWRest():New(::cUrlBase + cCompUrl)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestPed:setPath("")

	If oRestPed:Get(aHeader)
		U_DH05A00L(::cEntid, "GET", oRestPed:cHost )

		If FWJsonDeserialize(oRestPed:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf

return oRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} CancelPed
//TODO Descrição auto-gerada.
@author Anasol
@since 30/11/2017
@version 1.0
@param cId, characters, descricao
@type function
/*/
method CancelPed( cId ) class MpPedidos
	Local oJson
	Local oRet		:= {}
	Local cCompUrl	:= ''
	Local cNewId	:= 0
	Local cNewUrl	:= ''
	Local cStatus	:= ''

	Default cId		:= ''
	Default cUltDt	:= ''

	If !Empty(cId)
		cCompUrl	:= '/cancelar/' + AllTrim( cId )
	Else 
		Return { Val(cNewId), cNewUrl, cStatus }
	EndIf

	oRestPed	:= FWRest():New(::cUrlBase + cCompUrl)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestPed:setPath("")

	If oRestPed:Post(aHeader)
		U_DH05A00L( ::cEntid, "POST", oRestPed:cHost )

		nPosID	:= ASCAN( oRestPed:oResponseH:aHeaderFields,{|x| AllTrim( x[1] ) == "MeusPedidosID"} )
		nPosURL	:= ASCAN( oRestPed:oResponseH:aHeaderFields,{|x| AllTrim( x[1] ) == "MeusPedidosURL"} )

		If nPosId > 0
			cNewId := AllTrim( oRestPed:oResponseH:aHeaderFields[ nPosID ][2] )
		EndIf

		If nPosURL > 0
			cNewUrl := AllTrim( oRestPed:oResponseH:aHeaderFields[ nPosURL ][2] )
		EndIf
	Else
		U_DH05A00L( ::cEntid, "POST", oRestPed:cHost )

	EndIf

	cStatus	:= oRestPed:oResponseH:cStatusCode
	oRet	:= { Val(cNewId), oRestPed:cHost, cStatus }

return oRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} PostProd
//TODO Descrição auto-gerada.
@author Anasol
@since 25/01/2018
@version 1.0
@type function
/*/
method PostPed() class MpPedidos
	Local cJson		:= ""
	Local cNewId	:= '0'
	Local cNewUrl	:= ""
	Local aPed		:= {}
	Local cError	:= ""

	oRestPed := FWRest():New( ::cUrlBase )

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadPed() )

	oRestPed:setPath("")
	oRestPed:SetPostParams(cJson)

	If oRestPed:Post(aHeader)
		U_DH05A00L( ::cEntid, "POST", oRestPed:cHost )

		nPosID	:= ASCAN( oRestPed:oResponseH:aHeaderFields,{|x| AllTrim( x[1]) == "MeusPedidosID"} )
		nPosURL	:= ASCAN( oRestPed:oResponseH:aHeaderFields,{|x| AllTrim( x[1]) == "MeusPedidosURL"} )

		If nPosId > 0
			cNewId := alltrim(oRestPed:oResponseH:aHeaderFields[ nPosID ][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestPed:oResponseH:aHeaderFields[ nPosURL ][2])
		EndIf
	Else
		U_DH05A00L( ::cEntid, "POST", oRestPed:cHost )
	EndIf

	cStatus	:= oRestPed:oResponseH:cStatusCode
	cError	:= oRestPed:cResult
	aPed	:= { Val(cNewId), oRestPed:cHost, cStatus, cError }

return aPed

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} PutPed
//TODO Descrição auto-gerada.
@author Anasol
@since 29/01/2018
@version 1.0
@type function
/*/
method PutPed( cId ) class MpPedidos
	Local cJson		:= ""
	Local cNewId	:= "0"
	Local cNewUrl	:= ""
	Local aPed		:= {}
	Local cError	:= ""

	oRestPed := FWRest():New( ::cUrlBase + '/' + AllTrim( cValToChar( cId ) ) )

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppsToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadPed() )

	oRestPed:setPath("")
	oRestPed:SetPostParams( cJson )

	If oRestPed:Put( aHeader, cJson )
		U_DH05A00L( ::cEntid, "PUT", oRestPed:cHost )

		nPosID	:= ASCAN( oRestPed:oResponseH:aHeaderFields, {|x| AllTrim(x[1]) == "MeusPedidosID"})
		nPosURL	:= ASCAN( oRestPed:oResponseH:aHeaderFields, {|x| AllTrim(x[1]) == "MeusPedidosURL"})

		If nPosId > 0
			cNewId := AllTrim( oRestPed:oResponseH:aHeaderFields[ nPosID ][2] )
		EndIf

		If nPosURL > 0
			cNewUrl := AllTrim( oRestPed:oResponseH:aHeaderFields[ nPosURL ][2] )
		EndIf
	Else
		U_DH05A00L( ::cEntid, "PUT", oRestPed:cHost )
	EndIf

	cStatus	:= oRestPed:oResponseH:cStatusCode
	cError	:= oRestPed:cResult
	aPed	:= { Val(cNewId), oRestPed:cHost, cStatus, cError }

return aPed

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} PostPedEdi
//TODO Descrição auto-gerada.
@author Anasol
@since 12/11/2018
@version 1.0
@type function
/*/
method PostPedEdi( aPedEdi ) class MpPedidos
	Local cJson		:= ""
	Local cNewId	:= '0'
	Local cNewUrl	:= ""
	Local aPed		:= {}
	Local cError	:= ""

	oRestPed := FWRest():New( ::cUrlBase )

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( aPedEdi )

	oRestPed:setPath("")
	oRestPed:SetPostParams(cJson)

	If oRestPed:Post(aHeader)
		U_DH05A00L( ::cEntid, "POST", oRestPed:cHost )

		nPosID	:= ASCAN( oRestPed:oResponseH:aHeaderFields,{|x| AllTrim( x[1]) == "MeusPedidosID"} )
		nPosURL	:= ASCAN( oRestPed:oResponseH:aHeaderFields,{|x| AllTrim( x[1]) == "MeusPedidosURL"} )

		If nPosId > 0
			cNewId := alltrim(oRestPed:oResponseH:aHeaderFields[ nPosID ][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestPed:oResponseH:aHeaderFields[ nPosURL ][2])
		EndIf
	Else
		U_DH05A00L( ::cEntid, "POST", oRestPed:cHost )
	EndIf

	cStatus	:= oRestPed:oResponseH:cStatusCode
	cError	:= oRestPed:cResult
	aPed	:= { Val(cNewId), oRestPed:cHost, cStatus, cError, cJson }

return aPed

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadPed
//TODO Descrição auto-gerada.
@author Anasol
@since 25/01/2018
@version 1.0
@type function
/*/
Static Function LoadPed()
	Local aItens	:= {}
	local cItens	:= ""
	Local aValores	:= {}
	Local aRet		:= {}

	cIdClie		:= Str(Posicione("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE, "A1_IDMP"))
	cDtEmissao	:= DTOS(SC5->C5_EMISSAO) 
	cDtEmissao	:= SubStr(cDtEmissao,1,4) + '-' + SubStr(cDtEmissao,5,2) + '-' + SubStr(cDtEmissao,7,2)
	cIdContato	:= 'null'
	cIdTransp	:= Str(Posicione("SA4", 1, xFilial("SA4") + SC5->C5_TRANSP, "A4_IDMP"))
	cIdVend		:= Str(Posicione("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_IDMP"))
	cIdCondPag	:= 'null'
	cCondPag	:= AllTrim(Posicione("SE4", 1, xFilial("SE4") + SC5->C5_CONDPAG, "E4_DESCRI"))
	cObs		:= ''

	DBSelectArea("SC6")
	SC6->( DBSetOrder(1) )
	SC6->( DBGoTop() )

	If SC6->( DBSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
		While !SC6->( EOF() ) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
			aItens := {}

			cIdProduto	:= Str(Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_IDMP"))
			cIdTab		:= 'null'
			cQtd		:= cValToChar(SC6->C6_QTDVEN)
			cDesc		:= IIF( '910' $ SC6->C6_CF, '99.99', '0.00' )
			cPrcliq		:= IIF( '910' $ SC6->C6_CF, '0.01', cValToChar(SC6->C6_PRUNIT) )
			cPrcBrut	:= cValToChar(SC6->C6_PRUNIT)
			cObsItem	:= IIF( '910' $ SC6->C6_CF, 'Item Bonificado', '' )
			cTpIpi		:= 'P'											// P = Percentual, V = Valor

			aValores	:= U_DHCALCIMP( SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_TIPOCLI,;
				SC6->C6_PRODUTO, SC6->C6_TES, SC6->C6_QTDVEN, SC6->C6_PRUNIT, SC6->C6_VALOR, 0, 1, .f.)

			cIpi		:= cValToChar( aValores[5] )
			cSt			:= cValToChar( aValores[3] )

			AADD(aItens,{ "produto_id"		, AllTrim(cIdProduto)		, "Integer"	, 0})
			AADD(aItens,{ "tabela_preco_id"	, AllTrim(cIdTab)			, "Integer"	, 0})
			AADD(aItens,{ "quantidade"		, AllTrim(cQtd)				, "Double"	, 0})
			AADD(aItens,{ "preco_bruto"		, AllTrim(cPrcBrut)			, "Double"	, 0})
			If cDesc == '99.99'
				AADD(aItens,{ "descontos"	, '[99.99]'					, "Json"	, 0})
			EndIf
			AADD(aItens,{ "preco_liquido"	, AllTrim(cPrcLiq)			, "Double"	, 0})
			AADD(aItens,{ "observacoes"		, AllTrim(cObsItem)			, "String"	, 0})
			AADD(aItens,{ "ipi"				, AllTrim(cIpi)				, "Double"	, 0})
			AADD(aItens,{ "tipo_ipi"		, AllTrim(cTpIpi)			, "String"	, 1})
			AADD(aItens,{ "st"				, AllTrim(cSt)				, "Double"	, 0})

			cItens	+= MontaJson( aItens )

			SC6->( DBSkip() )
		EndDo

		cItens := '[' + StrTran( cItens, '}{', '},{' ) + ']'
	EndIf

	/* --- Cabeçalho Pedido Venda --- */
	AADD(aRet,{ "cliente_id"			, AllTrim(cIdClie)				, "Integer"	, 0})
	AADD(aRet,{ "data_emissao"			, AllTrim(cDtEmissao)			, "String"	, 10})
	AADD(aRet,{ "contato_id"			, AllTrim(cIdContato)			, "Integer"	, 0})
	AADD(aRet,{ "transportadora_id"		, AllTrim(cIdTransp)			, "Integer"	, 0})
	AADD(aRet,{ "criador_id"			, AllTrim(cIdVend)				, "Integer"	, 0})
	AADD(aRet,{ "condicao_pagamento_id"	, AllTrim(cIdCondPag)			, "Integer"	, 0})
	AADD(aRet,{ "condicao_pagamento"	, AllTrim(cCondPag)				, "String"	, 100})
	AADD(aRet,{ "observacoes"			, AllTrim(cObs)					, "String"	, 0})
	AADD(aRet,{ "itens"					, AllTrim(cItens)				, "Json"	, 0})

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

	cJson := ''

	For x := 1 to Len(aDados)
		cJson += '"' + aDados[x][1] + '": '

		if aDados[x][3] == 'String'
			if len(aDados[x][2]) > aDados[x][4] .And. aDados[x][4] <> 0
				cJson += '"' + SubStr(aDados[x][2], 1, aDados[x][4]) + '"'
			else
				cJson += '"' + aDados[x][2] + '"'
			endif

		elseif aDados[x][3] == 'Json'
			cJson += aDados[x][2]

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
			cJson += ',' + CRLF
		endif

	Next x

	cJson := '{' + CRLF + cJson + '}'

Return cJson
