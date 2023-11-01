async function fazerLogin(email, password) {
    try {
        const url = 'login.php';

        const response = await fetch(url, {
            method: 'POST', // Altere o método para POST
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`, // Envie no corpo da solicitação
        });

        console.log('Response status:', response.status);

        if (response.ok) {
            const data = await response.json();
            console.log('Data from server:', data);

            if (data.status === true) {
                console.log('Redirecionando para /index.html');
                window.location.href = '/site.html'; // Redirecionar para a página principal
            } else {
                console.log('Credenciais inválidas. Tente novamente.');
                mostrarMensagemErro('Credenciais inválidas. Tente novamente.');
            }
        } else {
            console.log('Error response:', response.statusText);
            mostrarMensagemErro('Erro ao fazer login. Tente novamente mais tarde.');
        }
    } catch (error) {
        console.error('Erro ao fazer login:', error);
        mostrarMensagemErro('Erro ao fazer login. Tente novamente mais tarde.');
    }
}

function mostrarMensagemErro(mensagem) {
    const mensagemErro = document.getElementById('error-message');
    mensagemErro.textContent = mensagem;
}

document.getElementById('login-form').addEventListener('submit', function (event) {
    event.preventDefault();

    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    fazerLogin(email, password);
});
