from app.core.cryptography import dek_utils
from app.core.cryptography.kms_providers import IKMSClient


class CryptoManager:

    def __init__(self, kms_client: IKMSClient):
        self.kms_client = kms_client


    # -- Método para encriptar un token con una DEK y aplicarle un WRAP 
    async def encrypt_tokens_with_key_wrapping(self, tokens: dict[str, bytes], kek_name : str, dek : bytes | None = None):
        if not dek: dek = dek_utils.generate_dek()

        encrypted_tokens = {} 

        for token_name, token_value in tokens.items():
            encrypted_token = dek_utils.encrypt_token_with_dek(token_value, dek)
            encrypted_tokens[token_name] = encrypted_token

        wrapped_dek = await self.kms_client.wrap_key(dek, kek_name)
        return encrypted_tokens, wrapped_dek


    # -- Método para desencriptar un token con una DEK wrappeada 
    async def decrypt_tokens_with_key_wrapping(self, encrypted_tokens: dict[str, bytes], wrapped_dek : bytes, kek_name : str):
        unwrapped_dek = await self.kms_client.unwrap_key(wrapped_dek, kek_name)
        decrypted_tokens = {} 
        
        for token_name, token_value in encrypted_tokens.items():
            decrypted_token = dek_utils.decrypt_token_with_dek(token_value, unwrapped_dek)
            decrypted_tokens[token_name] = decrypted_token

        #Nota: Se devuelve también la DEK unwrappeada para mantenerla en caché unos minutos, y evitar muchas llamadas al KV en caso de que se realicen llamadas constantes al servicio
        return decrypted_tokens, unwrapped_dek  
