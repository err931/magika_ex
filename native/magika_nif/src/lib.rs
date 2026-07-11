use magika::Session;
use rustler::{Binary, Env, NifResult, ResourceArc, Term};
use std::sync::Mutex;

struct MagikaResource {
    session: Mutex<Session>,
}

#[derive(rustler::NifStruct)]
#[module = "MagikaEx.Result"]
struct MagikaResult {
    /// The unique label identifying this file type.
    pub label: String,

    /// The MIME type of the file type.
    pub mime_type: String,

    /// The group of the file type.
    pub group: String,

    /// The description of the file type.
    pub description: String,

    /// The inference score between 0 and 1.
    pub score: f32,

    /// Whether the file type is text.
    pub is_text: bool,
}

#[rustler::nif]
fn new() -> NifResult<ResourceArc<MagikaResource>> {
    let session = Session::new().map_err(|e| {
        rustler::Error::Term(Box::new(format!(
            "Failed to create Magika session: {:?}",
            e
        )))
    })?;

    Ok(ResourceArc::new(MagikaResource {
        session: Mutex::new(session),
    }))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn identify_bytes(resource: ResourceArc<MagikaResource>, data: Binary) -> NifResult<MagikaResult> {
    let mut session = resource
        .session
        .lock()
        .map_err(|_| rustler::Error::Term(Box::new("Failed to lock magika session mutex")))?;

    let result = session
        .identify_content_sync(data.as_slice())
        .map_err(|e| rustler::Error::Term(Box::new(format!("Magika error: {:?}", e))))?;

    let info = result.info();
    let score = result.score();

    let response = MagikaResult {
        label: info.label.to_string(),
        mime_type: info.mime_type.to_string(),
        group: info.group.to_string(),
        description: info.description.to_string(),
        score,
        is_text: info.is_text,
    };

    Ok(response)
}

#[allow(non_local_definitions)]
fn on_load(env: Env, _info: Term) -> bool {
    let _ = rustler::resource!(MagikaResource, env);
    true
}

rustler::init!("Elixir.MagikaEx.Native", load = on_load);
