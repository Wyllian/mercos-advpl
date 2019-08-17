#include 'protheus.ch'

/*/{Protheus.doc} MpFatPed
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpFatPed
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method New()										// Constructor
	method FatPed()										// Fatura o Pedido Venda
	method AltFatPed()									// Altera o Faturamento Pedido de Venda

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
method New() class MpFatPed
	::cEntid	:= "faturamento"
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
method FatPed( nValor ) class MpFatPed
	Local cJson		:= ''
	Local oRet		:= {}
	Local cCompUrl	:= ''
	Local cNewId	:= 0
	Local cNewUrl	:= ''
	Local cStatus	:= ''

	Private nVlrFat	:= nValor

	oRestFat	:= FWRest():New( ::cUrlBase )

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadFat() )

	oRestFat:setPath("")
	oRestFat:SetPostParams(cJson)

	If oRestFat:Post( aHeader )
		U_DH05A00L( ::cEntid, "POST", oRestFat:cHost, cJson )

		nPosID	:= ASCAN( oRestFat:oResponseH:aHeaderFields, {|x| AllTrim( x[1] ) == "MeusPedidosID"} )
		nPosURL	:= ASCAN( oRestFat:oResponseH:aHeaderFields, {|x| AllTrim( x[1] ) == "MeusPedidosURL"} )

		If nPosId > 0
			cNewId := AllTrim( oRestFat:oResponseH:aHeaderFields[ nPosID ][2] )
		EndIf

		If nPosURL > 0
			cNewUrl := AllTrim( oRestFat:oResponseH:aHeaderFields[ nPosURL ][2] )
		EndIf
	Else
		U_DH05A00L( ::cEntid, "POST", oRestFat:cHost, cJson )

	EndIf

	cStatus	:= oRestFat:oResponseH:cStatusCode
	oRet	:= { Val(cNewId), cNewUrl, cStatus }

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
method AltFatPed( cId, nValor ) class MpFatPed
	Local cJson
	Local oRet		:= {}
	Local cCompUrl	:= ''
	Local cNewId	:= 0
	Local cNewUrl	:= ''
	Local cStatus	:= ''

	Private nVlrFat	:= nValor

	Default cId		:= ''
	Default cUltDt	:= ''

	If !Empty(cId)
		cCompUrl	:= '/cancelar/' + AllTrim( Str( cId ) )
	Else 
		Return { Val(cNewId), cNewUrl, cStatus }
	EndIf

	cJson := MontaJson( LoadFat() )

	oRestFat := FWRest():New( ::cUrlBase + cCompUrl )

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestFat:SetPath("")
	oRestFat:SetPostParams( cJson )

	If oRestFat:Put( aHeader, cJson )
		U_DH05A00L( ::cEntid, "PUT", oRestFat:cHost, cJson )

		nPosID	:= ASCAN( oRestFat:oResponseH:aHeaderFields,{|x| AllTrim( x[1] ) == "MeusPedidosID"} )
		nPosURL	:= ASCAN( oRestFat:oResponseH:aHeaderFields,{|x| AllTrim( x[1] ) == "MeusPedidosURL"} )

		If nPosId > 0
			cNewId := AllTrim( oRestFat:oResponseH:aHeaderFields[ nPosID ][2] )
		EndIf

		If nPosURL > 0
			cNewUrl := AllTrim( oRestFat:oResponseH:aHeaderFields[ nPosURL ][2] )
		EndIf
	Else
		U_DH05A00L( ::cEntid, "PUT", oRestFat:cHost, cJson )

	EndIf

	cStatus	:= oRestFat:oResponseH:cStatusCode
	oRet	:= { Val(cNewId), cNewUrl, cStatus }

Return oRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadFat
//TODO Descrição auto-gerada.
@author Anasol
@since 30/11/2017
@version 1.0
@type function
/*/
Static Function LoadFat()
	Local aRet := {}

	cIdPed		:= AllTrim( Str( SC5->C5_IDMP ) )
	cValFat		:= nVlrFat

	xDataFat	:= DToS( Date() )
	cDataFat	:= SubStr( xDataFat, 1, 4 ) + '-' + SubStr( xDataFat, 5, 2 ) + '-' + SubStr( xDataFat, 7, 2 ) 
	cNum		:= 'null'
	cInfoAd		:= 'null'

	AADD(aRet,{ "pedido_id"					, cIdPed						, "Integer"	, 0})
	AADD(aRet,{ "valor_faturado"			, cValFat						, "Double"	, 0})
	AADD(aRet,{ "data_faturamento"			, cDataFat						, "String"	, 10})
	AADD(aRet,{ "numero_nf"					, cNum							, "String"	, 500})
	AADD(aRet,{ "informacoes_adicionais"	, cInfoAd						, "String"	, 500})

Return aRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} MontaJson
//TODO Descrição auto-gerada.
@author Anasol
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
