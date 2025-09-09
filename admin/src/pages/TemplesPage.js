import React, { useState } from 'react';
import {
  Box,
  Typography,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
} from '@mui/material';
import { Add } from '@mui/icons-material';
import { useDropzone } from 'react-dropzone';
import { adminAPI } from '../services/api';
import toast from 'react-hot-toast';

function TemplesPage() {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    location: '',
    lat: '',
    lng: '',
    history: '',
    description: '',
    timings: {
      morning: '',
      evening: '',
    },
    amenities: [],
    rituals: [],
  });
  const [images, setImages] = useState([]);

  const { getRootProps, getInputProps } = useDropzone({
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.gif']
    },
    onDrop: (acceptedFiles) => {
      setImages(acceptedFiles);
    }
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    if (name.includes('.')) {
      const [parent, child] = name.split('.');
      setFormData(prev => ({
        ...prev,
        [parent]: {
          ...prev[parent],
          [child]: value
        }
      }));
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: value
      }));
    }
  };

  const handleSubmit = async () => {
    try {
      setLoading(true);
      const submitData = new FormData();
      
      // Add form data
      Object.keys(formData).forEach(key => {
        if (key === 'timings' || key === 'amenities' || key === 'rituals') {
          submitData.append(key, JSON.stringify(formData[key]));
        } else {
          submitData.append(key, formData[key]);
        }
      });

      // Add images
      images.forEach((image, index) => {
        submitData.append('images', image);
      });

      await adminAPI.createTemple(submitData);
      toast.success('Temple created successfully');
      setOpen(false);
      setFormData({
        name: '',
        location: '',
        lat: '',
        lng: '',
        history: '',
        description: '',
        timings: { morning: '', evening: '' },
        amenities: [],
        rituals: [],
      });
      setImages([]);
    } catch (error) {
      toast.error('Failed to create temple');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" component="h1">
          Temple Management
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => setOpen(true)}
        >
          Add Temple
        </Button>
      </Box>

      <Dialog open={open} onClose={() => setOpen(false)} maxWidth="md" fullWidth>
        <DialogTitle>Add New Temple</DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label="Temple Name"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                fullWidth
                label="Location"
                name="location"
                value={formData.location}
                onChange={handleChange}
                required
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="Latitude"
                name="lat"
                type="number"
                value={formData.lat}
                onChange={handleChange}
                required
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="Longitude"
                name="lng"
                type="number"
                value={formData.lng}
                onChange={handleChange}
                required
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="History"
                name="history"
                multiline
                rows={3}
                value={formData.history}
                onChange={handleChange}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Description"
                name="description"
                multiline
                rows={3}
                value={formData.description}
                onChange={handleChange}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="Morning Timings"
                name="timings.morning"
                value={formData.timings.morning}
                onChange={handleChange}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="Evening Timings"
                name="timings.evening"
                value={formData.timings.evening}
                onChange={handleChange}
              />
            </Grid>
            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom>
                Upload Images
              </Typography>
              <Box
                {...getRootProps()}
                sx={{
                  border: '2px dashed #ccc',
                  borderRadius: 2,
                  p: 3,
                  textAlign: 'center',
                  cursor: 'pointer',
                  '&:hover': {
                    borderColor: 'primary.main',
                  },
                }}
              >
                <input {...getInputProps()} />
                <Typography>
                  Drag & drop images here, or click to select files
                </Typography>
                {images.length > 0 && (
                  <Box sx={{ mt: 2 }}>
                    {images.map((file, index) => (
                      <Chip
                        key={index}
                        label={file.name}
                        onDelete={() => setImages(images.filter((_, i) => i !== index))}
                        sx={{ mr: 1, mb: 1 }}
                      />
                    ))}
                  </Box>
                )}
              </Box>
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpen(false)}>Cancel</Button>
          <Button onClick={handleSubmit} variant="contained" disabled={loading}>
            {loading ? 'Creating...' : 'Create Temple'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default TemplesPage;