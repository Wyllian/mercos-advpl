#include 'protheus.ch'

/*/{Protheus.doc} MpPrcXClie
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpPrcXClie
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method new() constructor
	method PostPrcXClie()							// Liberação Tabela Vs Cliente
	method PostLibAll()								// Libera Todas as Tabelas Preço

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
method new() class MpPrcXClie
	::cEntid	:= "clientes_tabela_preco"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostPrcXClie
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PostPrcXClie() class MpPrcXClie
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aPrcXClie		:= {}

	oRestXClie := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadPrcCli() )

	oRestXClie:setPath("")
	oRestXClie:SetPostParams(cJson)

	If oRestXClie:Post(aHeader)
		U_DH05A00L("clientes_tabela_preco","POST",oRestXClie:cHost,cJson)

		nPosID	:= ASCAN(oRestXClie:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestXClie:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestXClie:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestXClie:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus		:= oRestXClie:oResponseH:cStatusCode
	aPrcXClie	:= { Val(cNewId), cNewUrl, cStatus }

return aPrcXClie

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostLibAll
//TODO Descrição auto-gerada.
@author Anasol
@since 07/11/2017
@version 1.0
@type function
/*/
method PostLibAll() class MpPrcXClie
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aPrcXClie		:= {}

	oRestXClie := FWRest():New(::cUrlBase + '/liberar_todas')

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadLibAll() )

	oRestXClie:setPath("")
	oRestXClie:SetPostParams(cJson)

	If oRestXClie:Post(aHeader)
		U_DH05A00L("clientes_tabela_preco","POST",oRestXClie:cHost,cJson)

		nPosID	:= ASCAN(oRestXClie:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestXClie:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestXClie:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestXClie:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus		:= oRestXClie:oResponseH:cStatusCode
	aPrcXClie	:= { Val(cNewId), cNewUrl, cStatus }

return aPrcXClie


/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadPrcXClie
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined
@type function
/*/
Static Function LoadPrcCli()
	Local aRet		:= {}
	Local nIdTabMP	:= Posicione("DA0", 1, xFilial("DA0") + SA1->A1_TABELA, "DA0_IDMP")

	cIdClie		:= cValToChar(SA1->A1_IDMP)
	cTabLib		:= '[' + Str(nIdTabMP) + ']'

	AADD(aRet,{ "cliente_id"		, IIF(!Empty(cIdClie), cIdClie, 'null')		, "Integer"	, 0})
	AADD(aRet,{ "tabelas_liberadas"	, IIF(!Empty(cTabLib), cTabLib, 'null')		, "Array"	, 0})

Return aRet

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} LoadLibAll
//TODO Descrição auto-gerada.
@author Anasol
@since 07/11/2017
@version 1.0
@type function
/*/
Static Function LoadLibAll()
	Local aRet		:= {}
	Local nIdTabMP	:= Posicione("DA0", 1, xFilial("DA0") + SA1->A1_TABELA, "DA0_IDMP")

	cIdClie		:= cValToChar(SA1->A1_IDMP)

	AADD(aRet,{ "cliente_id"		, IIF(!Empty(cIdClie), cIdClie, 'null')		, "Integer"	, 0})
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
