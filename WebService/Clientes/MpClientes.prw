#include 'protheus.ch'

/*/{Protheus.doc} MpClientes
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpClientes
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA nId
	DATA cUltDt

	method New() constructor
	method GetClie( nId, cUltDt)				// Obtem Cliente
	method PostClie()							// Incluir Cliente
	method PutClie(cId)							// Altera Cliente

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
method new() class MpClientes
	::cEntid	:= "clientes"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid
return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetClie
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method GetClie( nId, cUltDt) class MpClientes
	Local oJson
	Local oRet		:= {}
	Local cCompUrl	:= ''

	Default nId		:= 0
	Default cUltDt	:= ''

	If nId > 0
		cCompUrl	:= '/' + AllTrim( Str(nId) )
	Else
		If !Empty(cUltDt)
			cUltDt		:= StrTran( cUltDt, ' ','%20')
			cCompUrl	:= '?alterado_apos=' + AllTrim(cUltDt)
		EndIf
	EndIf

	oRestClie := FWRest():New(::cUrlBase + cCompUrl)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestClie:setPath("")

	If oRestClie:Get(aHeader)
		U_DH05A00L("clientes","GET",oRestClie:cHost,oRestClie:cResult)

		If FWJsonDeserialize(oRestClie:cResult, @oJson)
			oRet := oJson
		EndIf
	Else

	EndIf

return oRet

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostClie
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PostClie() class MpClientes
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aClie		:= {}
	Local cErro		:= ""
	Private oJson

	oRestClie := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadClie() )

	oRestClie:setPath("")
	oRestClie:SetPostParams(cJson)

	If oRestClie:Post(aHeader)
		U_DH05A00L("clientes","POST",oRestClie:cHost,cJson)

		nPosID	:= ASCAN(oRestClie:oResponseH:aHeaderFields,{|x| AllTrim(x[1]) == "MeusPedidosID"})
		nPosURL	:= ASCAN(oRestClie:oResponseH:aHeaderFields,{|x| AllTrim(x[1]) == "MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestClie:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestClie:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus	:= AllTrim(oRestClie:oResponseH:cStatusCode)
	If cStatus >= '400'
/*		If FWJsonDeserialize(oRestClie:cResult, @oJson)
			cErro := oJson:erros:mensagem + ': ' + oJson:erros:campo
		EndIf */
	EndIf
	aClie	:= { Val(cNewId), cNewUrl, cStatus, cJson }

return aClie

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutClie
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PutClie(cId) class MpClientes
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local aClie		:= {}
	Local _y		:= 0
	Local cErro		:= ""

	oRestClie := FWRest():New(::cUrlBase + '/' + AllTrim(cValToChar(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadClie() )

	oRestClie:setPath("")
	oRestClie:SetPostParams(cJson)

	If oRestClie:Put(aHeader, cJson)
		U_DH05A00L("clientes","PUT",oRestClie:cHost,cJson)

		nPosID	:= ASCAN(oRestClie:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestClie:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestClie:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestClie:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus	:= oRestClie:oResponseH:cStatusCode
	If SubStr(cStatus,1,1) == '4'
/*		If FWJsonDeserialize(oRestClie:cResult, @oJson)
			cErro := oJson:erros:mensagem + ': ' + oJson:erros:campo
		EndIf */
	EndIf
	aClie	:= { Val(cNewId), cNewUrl, cStatus, cErro }

return aClie

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadClie
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined

@type function
/*/
Static Function LoadClie()
	Local aRet := {}

	cNome		:= AllTrim(SA1->A1_NOME)
	cNReduz		:= AllTrim(SA1->A1_NREDUZ)
	cTipo		:= AllTrim(SA1->A1_PESSOA)
	cCgc		:= AllTrim(SA1->A1_CGC)
	cInscr		:= AllTrim(SA1->A1_INSCR)
	cSuframa	:= ""
	cRua		:= AllTrim(SA1->A1_END)
	cComplem	:= AllTrim(SA1->A1_COMPLEM)
	cBairro		:= AllTrim(SA1->A1_BAIRRO)
	cCep		:= AllTrim(SA1->A1_CEP)
	cCidade		:= AllTrim(SA1->A1_MUN)
	cEstado		:= AllTrim(SA1->A1_EST)
	cObs		:= ""
	/* ------------------------------------------------------------------------------- */
	If Empty(SA1->A1_EMAIL) .And. Empty(SA1->A1_EMAIL2)
		cEmail	:= ''
	Else
		cEmail	:= '[ '
		If !Empty(SA1->A1_EMAIL)
			cEmail	+= '{ "email":"'+ AllTrim(SA1->A1_EMAIL) +'" }'
		EndIf
		If !Empty(SA1->A1_EMAIL2)
			cEmail	+= IIF(!Empty(SA1->A1_EMAIL),', ','')
			cEmail	+= '{ "email":"'+ AllTrim(SA1->A1_EMAIL) +'" }'
		EndIf
		cEmail	+= ' ]'
	EndIf
	/* ------------------------------------------------------------------------------- */
	If Empty(SA1->A1_TEL) .And. Empty(SA1->A1_CELULAR) .And. Empty(SA1->A1_FAX)
		cTelefones	:= ''
	Else
		cTelefones	:= '[ '
		If !Empty(SA1->A1_TEL)
			cTelefones	+= '{ "numero":"('+ AllTrim(SA1->A1_DDD) +')'+ AllTrim(SA1->A1_TEL) +'" }'
		EndIf
		If !Empty(SA1->A1_CELULAR)
			cTelefones	+= IIF(!Empty(SA1->A1_TEL),', ','')
			cTelefones	+= '{ "numero":"'+ AllTrim(SA1->A1_CELULAR) +'" }'
		EndIf
		If !Empty(SA1->A1_FAX)
			cTelefones	+= IIF(Empty(SA1->A1_TEL) .And. Empty(SA1->A1_CELULAR),'',', ')
			cTelefones	+= '{ "numero":"('+ AllTrim(SA1->A1_DDD) +')'+ AllTrim(SA1->A1_FAX) +'" }'
		EndIf
		cTelefones	+= ' ]'
	EndIf
	/* -------------------------------------------------------------------------------- */
	cContatos	:= ''
	cNomExcFis	:= ''
	cDel		:= 'false'

	AADD(aRet,{ "razao_social"			, cNome										, "String"	, 100})
	AADD(aRet,{ "nome_fantasia"			, cNReduz									, "String"	, 100})
	AADD(aRet,{ "tipo"					, cTipo										, "String"	, 1})
	AADD(aRet,{ "cnpj"					, cCgc										, "String"	, 18})
	AADD(aRet,{ "inscricao_estadual"	, cInscr									, "String"	, 30})
	AADD(aRet,{ "suframa"				, cSuframa									, "String"	, 20})
	AADD(aRet,{ "rua"					, cRua										, "String"	, 100})
	AADD(aRet,{ "complemento"			, cComplem									, "String"	, 50})
	AADD(aRet,{ "bairro"				, cBairro									, "String"	, 30})
	AADD(aRet,{ "cep"					, cCep										, "String"	, 9})
	AADD(aRet,{ "cidade"				, cCidade									, "String"	, 50})
	AADD(aRet,{ "estado"				, cEstado									, "String"	, 2})
	AADD(aRet,{ "observacao"			, cObs										, "String"	, 500})
	AADD(aRet,{ "emails"				, IIF(!Empty(cEmail), cEmail, '[]')			, "Array"	, 0})
	AADD(aRet,{ "telefones"				, IIF(!Empty(cTelefones), cTelefones, '[]')	, "Array"	, 0})
	AADD(aRet,{ "contatos"				, IIF(!Empty(cContatos), cContatos, '[]')	, "Array"	, 0})
	AADD(aRet,{ "nome_excecao_fiscal"	, cNomExcFis								, "String"	, 20})
	AADD(aRet,{ "excluido"				, cDel										, "Boolean"	, 0})

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
