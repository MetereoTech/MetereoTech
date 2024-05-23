use std::process::{Command, Child};
use std::thread;
use std::time::{Duration, Instant};
use std::path::Path;
use log::{info, warn, error};

fn main() {
    simple_logger::init().unwrap(); // Inicializa o logger
    info!("Orchestrator started.");

    // Definir o intervalo de verificação como 15 minutos (900 segundos)
    let interval = Duration::from_secs(900);
    let mut gui_process: Option<Child> = None;

    loop {
        let start_time = Instant::now();

        if let Err(e) = cleanup_files() {
            error!("Failed to clean up files: {}", e);
        }

        if let Err(e) = execute_sequence() {
            error!("Error during execution sequence: {}", e);
        }

        // Verifica e reinicia a interface gráfica, se necessário
        gui_process = ensure_gui_running(gui_process);

        // Calcular quanto tempo levará para o próximo ciclo
        if let Some(elapsed) = start_time.elapsed().checked_sub(interval) {
            thread::sleep(interval - elapsed);
        }
    }
}

fn execute_sequence() -> Result<(), Box<dyn std::error::Error>> {
    start_process("Processamento_de_dados.pas", "fpc")?;
    wait_for_file("resultado.csv")?;

    start_process("modelagem_climatica.f90", "gfortran")?;
    wait_for_file("previsao.csv")?;

    start_process("gerador_csv_completo.cob", "cobc")?;
    wait_for_file("final.csv")?;

    Ok(())
}

fn start_process(file_name: &str, compiler: &str) -> std::io::Result<()> {
    info!("Starting process for file: {}", file_name);
    let output = Command::new(compiler)
        .arg(file_name)
        .output()?;

    if !output.status.success() {
        let error_message = format!("Process failed for file: {}, error: {}", file_name, String::from_utf8_lossy(&output.stderr));
        error!("{}", error_message);
        return Err(std::io::Error::new(std::io::ErrorKind::Other, error_message));
    }

    info!("Process completed for file: {}", file_name);
    Ok(())
}

fn ensure_gui_running(current_process: Option<Child>) -> Option<Child> {
    match current_process {
        Some(mut process) => {
            match process.try_wait() {
                Ok(Some(status)) if !status.success() => {
                    warn!("GUI process terminated unexpectedly, restarting...");
                    start_gui_process().ok()
                },
                Ok(None) => Some(process),
                Err(e) => {
                    error!("Failed to poll GUI process: {}", e);
                    None
                },
                _ => Some(process),
            }
        },
        None => {
            info!("Starting GUI process...");
            start_gui_process().ok()
        }
    }
}

fn start_gui_process() -> std::io::Result<Child> {
    Command::new("fpc")
        .arg("interface.pas")
        .spawn()
        .map_err(|e| {
            error!("Failed to start GUI process: {}", e);
            e
        })
}

fn cleanup_files() -> std::io::Result<()> {
    let files_to_delete = ["resultado.csv", "previsao.csv", "final.csv"];
    for file in &files_to_delete {
        if Path::new(file).exists() {
            std::fs::remove_file(file)?;
        }
    }
    info!("Cleaned up old files.");
    Ok(())
}

fn wait_for_file(file_name: &str) -> Result<(), Box<dyn std::error::Error>> {
    let wait_timeout = Instant::now() + Duration::from_secs(300); // 5 minutes max wait time
    while Instant::now() < wait_timeout {
        if Path::new(file_name).exists() {
            info!("File found: {}", file_name);
            return Ok(());
        }
        thread::sleep(Duration::from_secs(1));
    }
    Err(Box::new(std::io::Error::new(std::io::ErrorKind::TimedOut, "Timeout waiting for file")))
}
