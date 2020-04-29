import os

from downloadPipelineArtifacts import extract_zipped_artifacts

def test_csv_files_should_be_there_extracted_from_zipped_artifacts(tmpdir):
    #GIVEN our zipped artifacts are on test_data/test_temp
    #WHEN we extract test data to a temp directory
    csv_dir = tmpdir.mkdir("test_csv")
    extract_zipped_artifacts("test_data/test_tmp",csv_dir.dirname,"results.csv")
    #THEN all unzipped files should be there in csv form
    assert "7018.csv" in os.listdir(csv_dir.dirname)
    assert "7023.csv" in os.listdir(csv_dir.dirname)